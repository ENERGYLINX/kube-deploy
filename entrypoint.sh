#!/bin/sh

# Input configuration and validation

INPUT_RELEASE="${11}"
INPUT_NAMESPACE="${12}"
INPUT_CHART="$1"
INPUT_VALUES_FILE="$2"
INPUT_AWS_ACCESS_KEY="$3"
INPUT_AWS_SECRET_KEY="$4"
INPUT_KUBE="$5"
INPUT_REPLACE="$6"
INPUT_DELETE="$7"
INPUT_SET="$8"
INPUT_WAIT="$9"
INPUT_TIMEOUT="${10}"
INPUT_REGION="${13}"
INPUT_AZURE_USERNAME="${14}"
INPUT_AZURE_PASSWORD="${15}"
INPUT_AZURE_RESOURCE_GROUP="${16}"
INPUT_ATOMIC="${17}"

validation="0"

if [ -z "$INPUT_RELEASE" ]; then
    >&2 echo "release is required"
    validation=1
fi
if [ -z "$INPUT_NAMESPACE" ]; then
    >&2 echo "namespace is required"
    validation=1
fi

if [ -n "$INPUT_AZURE_USERNAME" -a -n "$INPUT_AWS_ACCESS_KEY"  ]; then
    >&2 echo "aws_access_key and azure_username cannot be passed same time"
    validation=1
fi

if [ -z "$INPUT_AZURE_USERNAME" -a -z "$INPUT_AWS_ACCESS_KEY"  ]; then
    >&2 echo "one of aws_access_key or azure_username has to be passed"
    validation=1
fi

if [ -n "$INPUT_AWS_ACCESS_KEY" -a -z "$INPUT_AWS_SECRET_KEY" ]; then
    >&2 echo "aws_secret_key is required"
    validation=1
fi

if [ -n "$INPUT_AZURE_USERNAME" -a -z "$INPUT_AZURE_PASSWORD" ]; then
    >&2 echo "azure_password is required"
    validation=1
fi

if [ -n "$INPUT_AZURE_USERNAME" -a -z "$INPUT_AZURE_RESOURCE_GROUP" ]; then
    >&2 echo "azure_resource_group is required"
    validation=1
fi




if [ -z "$INPUT_VALUES_FILE" -a !"$INPUT_DELETE" = "yes" ]; then
    >&2 echo "values_file is required"
    validation=1
fi
if [ -z "$INPUT_CHART"  -a !"$INPUT_DELETE" = "yes" ]; then
    >&2 echo "chart is required"
    validation=1
fi
if [ -z "$INPUT_KUBE" ]; then
    >&2 echo "kube is required"
    validation=1
fi
if [ "$INPUT_REPLACE" = "yes" -a "$INPUT_DELETE" = "yes" ]; then
    >&2 echo "delete and replace flags can't be both enabled"
    validation=1
fi

if [ "$validation" = "1" ]; then
    exit 1
fi

# Do nothing when helm is called during testing
if [ "$TEST" = "yes" ]; then
    alias helm="echo helm"
fi

# We get the EKS config
if [ -n "$INPUT_AWS_ACCESS_KEY" ]; then
    >&2 echo ".. gettings EKS kube config"
    export AWS_ACCESS_KEY_ID=$INPUT_AWS_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=$INPUT_AWS_SECRET_KEY
    if [ "$TEST" = "yes" ]; then
        echo aws eks --region "$INPUT_REGION" update-kubeconfig --name "$INPUT_KUBE"
    else
        aws eks --region "$INPUT_REGION" update-kubeconfig --name "$INPUT_KUBE"
    fi
fi

# Or Azure AKS config
if [ -n "$INPUT_AZURE_USERNAME" ]; then
    >&2 echo ".. gettings Azure kube config"
    if [ "$TEST" = "yes" ]; then
        echo az login -u "$INPUT_AZURE_USERNAME" -p "******"
        echo az aks get-credentials --resource-group "$INPUT_AZURE_RESOURCE_GROUP" --name "$INPUT_KUBE"
    else
        az login -u "$INPUT_AZURE_USERNAME" -p "$INPUT_AZURE_PASSWORD"
        az aks get-credentials --resource-group "$INPUT_AZURE_RESOURCE_GROUP" --name "$INPUT_KUBE"
    fi
fi

# Extra arguments added to the helm command
>&2 echo ".. preparing extra arguments"
extra_args=""
if [ "$INPUT_WAIT" = "yes" ]; then
    extra_args="$extra_args --wait"
fi
if [ -n "$INPUT_TIMEOUT"  ]; then
    extra_args="$extra_args --timeout=$INPUT_TIMEOUT"
fi
if [ -n "$INPUT_SET"  ]; then
    extra_args="$extra_args --set"
    extra_args="$extra_args `echo $INPUT_SET | sed "s/,/ --set /"`"
fi
if [ "$INPUT_ATOMIC" = "yes" ]; then
    extra_args="$extra_args --atomic"
fi


# Basic helm's calls
helm_install() {
    >&2 echo ".. helm install"
    if [ "$TEST" = "yes" ]; then
        echo helm install -n "$INPUT_NAMESPACE" $extra_args -f "$INPUT_VALUES_FILE" "$INPUT_RELEASE" "$INPUT_CHART"
    else
        helm install -n "$INPUT_NAMESPACE" $extra_args -f "$INPUT_VALUES_FILE" "$INPUT_RELEASE" "$INPUT_CHART"
    fi
}

helm_upgrade() {
    >&2 echo ".. helm upgrade"
    if [ "$TEST" = "yes" ]; then
        echo helm upgrade -n "$INPUT_NAMESPACE" -f "$INPUT_VALUES_FILE" $extra_args "$INPUT_RELEASE" "$INPUT_CHART"
    else
        helm upgrade -n "$INPUT_NAMESPACE" -f "$INPUT_VALUES_FILE" $extra_args "$INPUT_RELEASE" "$INPUT_CHART"
    fi
}

helm_delete() {
    >&2 echo ".. helm delete"
    if [ "$TEST" = "yes" ]; then
        echo helm delete -n "$INPUT_NAMESPACE" "$INPUT_RELEASE"
    else
        helm delete -n "$INPUT_NAMESPACE" "$INPUT_RELEASE"
    fi
}

# If the chart exists
if [ "$TEST_RELEASE_EXISTS" = "yes" -o `helm list -n "$INPUT_NAMESPACE" | grep "$INPUT_RELEASE" | wc -l` -gt 0 ]; then
    >&2 echo ".. existing release found"
    # And replace or delete flag is given, we delete the release
    if [ "$INPUT_DELETE" = "yes" -o "$INPUT_REPLACE" = "yes" ]; then
        helm_delete
    fi

    # If only replace flag is given we install the chart again
    if [ "$INPUT_REPLACE" = "yes" ]; then
        >&2 echo ".. replacing"
        helm_install
    # and if replace and delete flags are "no" we just upgrade
    else
        if [ ! "$INPUT_DELETE" = "yes" ]; then
            >&2 echo ".. upgrading"
            helm_upgrade
        fi
    fi
else
    >&2 echo ".. existing release not found"
    if [ ! "$INPUT_DELETE" = "yes" ]; then
        helm_install
    fi
fi
