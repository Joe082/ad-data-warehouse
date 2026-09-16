package com.atguigu.ad.spark;

import org.apache.commons.cli.*;
import org.apache.spark.SparkConf;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SaveMode;
import org.apache.spark.sql.SparkSession;

public class Hive2ClickHouse {

    public static void main(String[] args) {

        Options options = new Options();

        options.addOption(
                OptionBuilder.withLongOpt("hive_db")
                        .hasArg(true)
                        .isRequired(true)
                        .create()
        );

        options.addOption(
                OptionBuilder.withLongOpt("hive_table")
                        .hasArg(true)
                        .isRequired(true)
                        .create()
        );

        options.addOption(
                OptionBuilder.withLongOpt("hive_partition")
                        .hasArg(true)
                        .isRequired(true)
                        .create()
        );

        options.addOption(
                OptionBuilder.withLongOpt("ck_url")
                        .hasArg(true)
                        .isRequired(true)
                        .create()
        );

        options.addOption(
                OptionBuilder.withLongOpt("ck_table")
                        .hasArg(true)
                        .isRequired(true)
                        .create()
        );

        options.addOption(
                OptionBuilder.withLongOpt("batch_size")
                        .hasArg(true)
                        .isRequired(true)
                        .create()
        );

        CommandLineParser parser = new GnuParser();
        CommandLine cmd;

        try {
            cmd = parser.parse(options, args);
        } catch (ParseException e) {
            System.out.println(e.getMessage());

            HelpFormatter helpFormatter =
                    new HelpFormatter();

            helpFormatter.printHelp(
                    "--option argument",
                    options
            );

            return;
        }

        SparkConf sparkConf =
                new SparkConf()
                        .setAppName("hive2clickhouse");

        SparkSession sparkSession =
                SparkSession.builder()
                        .config(sparkConf)
                        .getOrCreate();

        String hiveTable = cmd.getOptionValue("hive_table");
        String partition = cmd.getOptionValue("hive_partition");

        String hdfsPath =
                "hdfs://ad-namenode:8020/warehouse/ad/dwd/"
                + hiveTable
                + "/dt="
                + partition;

        System.out.println("Reading ORC from: " + hdfsPath);

        Dataset<Row> hive =
                sparkSession.read()
                        .format("orc")
                        .load(hdfsPath);
        
        System.out.println("Hive ORC row count: " + hive.count());
        hive.show(5, false);

        hive.write()
                .mode(SaveMode.Append)
                .format("jdbc")
                .option(
                        "url",
                        cmd.getOptionValue("ck_url")
                )
                .option(
                        "dbtable",
                        cmd.getOptionValue("ck_table")
                )
                .option(
                        "driver",
                        "ru.yandex.clickhouse.ClickHouseDriver"
                )
                .option(
                        "batchsize",
                        cmd.getOptionValue("batch_size")
                )
                .save();

        sparkSession.close();
    }
}