#!/bin/bash

dti=$(date -u +%Y%m%d-%H%M%S)

#IMAGE="mage.name:${SOURCE_COMMIT}"
IMAGE="image.name:${dt1}"

docker build -t $IMAGE
docker tag "$IMAGE" "image.name:latest"
docker push $IMAGE
docker rmi "$IMAGE"

#Input arguments
env=$1
job=$2
type=$3

##Parse conf yaml
function parse_yaml {
  local prefix=$2
  local s='[[:space]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\):|\1|" \
      -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
  awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("export %s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
  }'
}

##parse conf using the parse function
parse_yaml conf.yaml >> temp.sh
chmod 777 temp.sh
. ./temp.sh
rm temp.sh

#settiing the variables
k8s_name_space=${env}_K8S_NS
cer=${env}_certificate
s3=${env}_s3_host
nodeIp=${env}_node_ip
sec=$env}_secrets
jobName=${env}_${job}_JOB
servName=${env}_${job}_SERVICE
confName=${env}_${job}_CONF
distPort=${env}_${job}_DIST
tableList=${env}_${job}_TL
scheduler=${env}_${job}_SCH
typ=${env}_${job}_TYPE

#set variables to script parameters
K8S_NAME_SPACE="${!k8s_name_space}"
JOB_NAME="${!jobName}"
SERVICE_NAME="${!servName}"
CERTIFICATE="${!cer}"
CONF="${!confName}"
ENV="${!env}"
DIST_PORT="${!distPort}"
S3_HOST="${!s3}"
NODE_IP="${!nodeIp}"
TABLE_LIST="${!tableList}"
SECRETS="${!sec}"
SCHEDULE="${!scheduler}"
JOB_TYPE="${!typ}"

##generate yaml to deploy via kubectl command
dt=$(date -u +%Y%m%d-%H%M%S)
generated_yaml=$(mktemp -p /tmp "yamlToDeploy-${dt}.XXXXXXXX.yaml")

cat > "${generated_yaml}" <<EOF

apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: $JOB_NAME
  namespace: $K8S_NAME_SPACE
spec:
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - env:
            - name:
              value:
            - name:
              value:
            - name:
              value:
            - name:
              value:
            - name:
              value:
            - name:
              value:
            - name:
              value:
            - name:
              value:
            - name:
              value:
            envFrom:
            - secretRef:
                name:
                optional: false
            image: ${IMAGE}
            imagePullPolicy: Always
            name:
            volumeMounts:
            - mountPath: /samplePath/
              name: job-logs
            terminationMessagePath: /dev/termination-logs
            terminationMesasagePolicy: FallbackToLogsOnError
            port:
            - containerPort:
              name:
              protocol:
          dnsPolicy: ClusterFirst
          restartPolicy: Never
          terminationGracePeriodSeconds: 30
          volumes:
          - name: job-logs
            persistentVolumeClaim:
              claimName:
schdule:
successfulJobsHistoryLimit: 3
suspend: false
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    field.cattle.io/targetWorkloadIds: '["cronjob:$K8S_NAME_SPACE:$JOB_NAME"]'
  name:
  namespace:
spec:
  externalTrafficPolicy: Cluster
  ports:
  - name:
    nodeport:
    port:
    protocol:
    targetPort:
  selector:
    workloadID_$SERVICE_NAME: "true"
  type: NodePort
status:
  loadBalancer: {}

EOF

#run kubectl command to start the pods
kubectl delete -f ${generated_yaml} || true
kubectl apply -f ${generated_yaml}

sleep 10










