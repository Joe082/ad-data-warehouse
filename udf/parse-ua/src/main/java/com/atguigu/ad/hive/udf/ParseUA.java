package com.atguigu.ad.hive.udf;

import cn.hutool.http.useragent.UserAgent;
import cn.hutool.http.useragent.UserAgentUtil;
import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;

import java.util.ArrayList;

public class ParseUA extends GenericUDF {

    @Override
    public ObjectInspector initialize(ObjectInspector[] arguments)
            throws UDFArgumentException {

        if (arguments.length != 1) {
            throw new UDFArgumentException("parse_ua函数需要1个参数");
        }

        ObjectInspector uaOI = arguments[0];

        if (uaOI.getCategory() != ObjectInspector.Category.PRIMITIVE) {
            throw new UDFArgumentException("parse_ua函数只接受基本数据类型参数");
        }

        PrimitiveObjectInspector primitiveUAOI =
                (PrimitiveObjectInspector) uaOI;

        if (primitiveUAOI.getPrimitiveCategory()
                != PrimitiveObjectInspector.PrimitiveCategory.STRING) {
            throw new UDFArgumentException("parse_ua函数只接受STRING类型参数");
        }

        ArrayList<String> fieldNames = new ArrayList<>();
        ArrayList<ObjectInspector> fieldOIs = new ArrayList<>();

        fieldNames.add("browser");
        fieldNames.add("browserVersion");
        fieldNames.add("engine");
        fieldNames.add("engineVersion");
        fieldNames.add("os");
        fieldNames.add("osVersion");
        fieldNames.add("platform");
        fieldNames.add("isMobile");

        for (int i = 0; i < 8; i++) {
            fieldOIs.add(
                PrimitiveObjectInspectorFactory.javaStringObjectInspector
            );
        }

        return ObjectInspectorFactory
                .getStandardStructObjectInspector(fieldNames, fieldOIs);
    }

    @Override
    public Object evaluate(DeferredObject[] arguments)
            throws HiveException {

        String ua = arguments[0].get().toString();

        UserAgent userAgent = UserAgentUtil.parse(ua);

        ArrayList<Object> result = new ArrayList<>();

        result.add(userAgent.getBrowser().getName());
        result.add(userAgent.getVersion());
        result.add(userAgent.getEngine().getName());
        result.add(userAgent.getEngineVersion());
        result.add(userAgent.getOs().getName());
        result.add(userAgent.getOsVersion());
        result.add(userAgent.getPlatform().getName());

        // Struct 中 isMobile 按课程定义为 String
        result.add(String.valueOf(userAgent.isMobile()));

        return result;
    }

    @Override
    public String getDisplayString(String[] children) {
        return getStandardDisplayString("parse_ua", children);
    }
}