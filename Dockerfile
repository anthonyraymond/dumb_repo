# Builder image with jdk
FROM openjdk:8u181-jre AS build


RUN apt-get update \
    && apt-get install -y git \
    && git clone https://github.com/anthonyraymond/joal.git --branch "v$JOAL_VERSION" --depth=1 \
    && cd joal \
    && mvn package -DskipTests=true \
    && mkdir /joal \
    && mv "target/jack-of-all-trades-$JOAL_VERSION.jar" /joal/


# Actual joal image with jre only
FROM openjdk:8u181-jre

COPY --from=build /joal/joal.jar /joal/joal.jar

VOLUME /data

ENTRYPOINT ["java","-jar","/joal/joal.jar"]
CMD ["--joal-conf=/data"]