package com.atguigu.ad.hive.udf;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDF;
import org.apache.hadoop.hive.serde2.objectinspector.ConstantObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;
import org.apache.hadoop.io.IOUtils;
import org.lionsoul.ip2region.xdb.Searcher;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;

public class ParseIP extends GenericUDF {

    private Searcher searcher;

    @Override
    public ObjectInspector initialize(ObjectInspector[] arguments)
            throws UDFArgumentException {

        if (arguments.length != 2) {
            throw new UDFArgumentException("parse_ip函数需要接受两个参数");
        }

        // 第一个参数：HDFS 中 ip2region.xdb 的路径
        ObjectInspector hdfsPathOI = arguments[0];

        if (hdfsPathOI.getCategory() != ObjectInspector.Category.PRIMITIVE) {
            throw new UDFArgumentException("parse_ip函数的第1个参数应为基本数据类型");
        }

        PrimitiveObjectInspector primitiveHttpURLOI =
                (PrimitiveObjectInspector) hdfsPathOI;

        if (PrimitiveObjectInspector.PrimitiveCategory.STRING
                != primitiveHttpURLOI.getPrimitiveCategory()) {
            throw new UDFArgumentException("parse_ip函数的第1个参数应为STRING类型");
        }

        // 把 IP 数据库加载进内存
        if (hdfsPathOI instanceof ConstantObjectInspector) {

            String filePath =
                    ((ConstantObjectInspector) hdfsPathOI)
                            .getWritableConstantValue()
                            .toString();

            Path path = new Path(filePath);
            Configuration conf = new Configuration();

            try {
                FileSystem fs = FileSystem.get(conf);

                FSDataInputStream inputStream = fs.open(path);

                ByteArrayOutputStream outputStream =
                        new ByteArrayOutputStream();

                IOUtils.copyBytes(inputStream, outputStream, 1024);

                byte[] buffer = outputStream.toByteArray();

                searcher = Searcher.newWithBuffer(buffer);

            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // 第二个参数：IP
        ObjectInspector ipOI = arguments[1];

        if (ipOI.getCategory() != ObjectInspector.Category.PRIMITIVE) {
            throw new UDFArgumentException("parse_ip函数的第2个参数应为基本数据类型");
        }

        PrimitiveObjectInspector primitiveIPOI =
                (PrimitiveObjectInspector) ipOI;

        if (PrimitiveObjectInspector.PrimitiveCategory.STRING
                != primitiveIPOI.getPrimitiveCategory()) {
            throw new UDFArgumentException("parse_ip函数的第2个参数应为STRING类型");
        }

        // 定义返回 Struct：
        // country, area, province, city, isp
        ArrayList<String> structFieldNames = new ArrayList<>();
        ArrayList<ObjectInspector> structFieldObjectInspectors =
                new ArrayList<>();

        structFieldNames.add("country");
        structFieldNames.add("area");
        structFieldNames.add("province");
        structFieldNames.add("city");
        structFieldNames.add("isp");

        for (int i = 0; i < 5; i++) {
            structFieldObjectInspectors.add(
                    PrimitiveObjectInspectorFactory.javaStringObjectInspector
            );
        }

        return ObjectInspectorFactory.getStandardStructObjectInspector(
                structFieldNames,
                structFieldObjectInspectors
        );
    }

    @Override
    public Object evaluate(DeferredObject[] arguments)
            throws HiveException {

        String ipAddress = arguments[1].get().toString();

        ArrayList<Object> result = new ArrayList<>();

        try {
            String region = searcher.search(ipAddress);

            String[] split = region.split("\\|");

            result.add(split[0]);
            result.add(split[1]);
            result.add(split[2]);
            result.add(split[3]);
            result.add(split[4]);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

    @Override
    public String getDisplayString(String[] children) {
        return getStandardDisplayString("parse_ip", children);
    }
}