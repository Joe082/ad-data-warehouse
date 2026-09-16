package com.atguigu.ad.flume.interceptor;

import org.apache.flume.Context;
import org.apache.flume.Event;
import org.apache.flume.interceptor.Interceptor;

import java.nio.charset.StandardCharsets;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class TimestampInterceptor implements Interceptor {

    private Pattern pattern;

    @Override
    public void initialize() {
        // 从日志中寻找 t=xxxxxxxxxxxxx
        // 例如：t=1673045381871
        pattern = Pattern.compile(".*t=(\\d{13}).*");
    }

    @Override
    public Event intercept(Event event) {

        String log = new String(event.getBody(), StandardCharsets.UTF_8);

        // 1. 移除日志最前面和最后面的双引号
        String subLog = log.substring(1, log.length() - 1);

        // 2. 去掉字段分隔符两侧的双引号
        String result = subLog.replaceAll("\"\u0001\"", "\u0001");

        event.setBody(result.getBytes(StandardCharsets.UTF_8));

        // 3. 从日志中提取 t= 后面的 13 位时间戳
        Matcher matcher = pattern.matcher(result);

        if (matcher.matches()) {

            String ts = matcher.group(1);

            // 4. 把时间戳写入 Flume Event Header
            event.getHeaders().put("timestamp", ts);

        } else {

            // 找不到时间戳的日志直接丢弃
            return null;
        }

        return event;
    }

    @Override
    public List<Event> intercept(List<Event> events) {

        Iterator<Event> iterator = events.iterator();

        while (iterator.hasNext()) {

            Event next = iterator.next();
            Event intercept = intercept(next);

            if (intercept == null) {
                iterator.remove();
            }
        }

        return events;
    }

    @Override
    public void close() {

    }

    public static class Builder implements Interceptor.Builder {

        @Override
        public Interceptor build() {
            return new TimestampInterceptor();
        }

        @Override
        public void configure(Context context) {

        }
    }
}