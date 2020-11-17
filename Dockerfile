FROM image.name/spark-py:2.4.4-hadoop-2.9.2

ENV https_proxy host:port
ENV http_proxy host:port
ENV TZ India/Chennai

RUN echo "http://dl-8.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk --no-chache --update-cache add gcc gfortran python3-dev build-base wget openblas-dev musl-dev gcompat libucontext musl
RUN apk --no-cache add curl
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install cython boto3 psycopg2 Jinja2 --no-cache-dir
RUN python3 -m pip install pyyaml
RUN python3 -m pip install avro-python3
RUN python3 -m pip install datetime
RUN python3 -m pip install pytz

copy . /app
WORKDIR /app

# import certificates necessary and import them

COPY lib/** ${SPARK_HOME}/jars/

RUN rm /opt/spark/jars/kubernetes*4.1.2.jar && cp /app/lib-override/* /opt/spark/jatrs \
    && rm -Rf /app/lib-override \
    && apk del gcc gfortran python3-dev build-base postgresql-dev musl-dev

RUN mkdir -p /app/etc/secrets
RUN chmod -R 777 /app/etc
RUN chmod -R +x /opt/spark/bin/*
RUN mkdir /app/logs
ENV PYSPARK_PYTHON=/usr/bin/python3

COPY entrypoint.sh /app/src/entrypoint.sh

RUN chmod _R +x /opt/spark/bin/*
RUN chmod 777 /app/src/*

ENTRYPOINT /app/src/entrypoint.sh
