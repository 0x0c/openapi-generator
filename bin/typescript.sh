#!/bin/sh

SCRIPT="$0"
echo "# START SCRIPT: $SCRIPT"

while [ -h "$SCRIPT" ] ; do
  ls=`ls -ld "$SCRIPT"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    SCRIPT="$link"
  else
    SCRIPT=`dirname "$SCRIPT"`/"$link"
  fi
done

if [ ! -d "${APP_DIR}" ]; then
  APP_DIR=`dirname "$SCRIPT"`/..
  APP_DIR=`cd "${APP_DIR}"; pwd`
fi

executable="./modules/openapi-generator-cli/target/openapi-generator-cli.jar"

if [ ! -f "$executable" ]
then
  mvn -B clean package
fi

# if you've executed sbt assembly previously it will use that instead.
export JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=256M -Xmx1024M -DloggerPath=conf/log4j.properties"
echo "Creating default (fetch) client!"
ags="generate -i modules/openapi-generator/src/test/resources/3_0/petstore.yaml -g typescript -o samples/openapi3/client/petstore/typescript/builds/default --additional-properties=platform=node,npmName=ts-petstore-client $@"

java $JAVA_OPTS -jar $executable $ags
echo "Creating jquery client!"
ags="generate -i modules/openapi-generator/src/test/resources/3_0/petstore.yaml  -g typescript -o samples/openapi3/client/petstore/typescript/builds/jquery --additional-properties=framework=jquery,npmName=ts-petstore-client $@"

java $JAVA_OPTS -jar $executable $ags

echo "Creating fetch object client!"
ags="generate -i modules/openapi-generator/src/test/resources/3_0/petstore.yaml  -g typescript -o samples/openapi3/client/petstore/typescript/builds/object_params --additional-properties=platform=node,npmName=ts-petstore-client,useObjectParameters $@"

java $JAVA_OPTS -jar $executable $ags
