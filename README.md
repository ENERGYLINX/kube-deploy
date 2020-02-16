# Kube deploy actions

This actions is designed for SwitchBit. It downloads kube configuration from AWS or Azure and deploys local or remote helm chart.

## Testing

If *entrypoint.sh* is run in environment where *TEST* variable contains 'yes' it just echo's the helm and aws commands.

Testing is implemented in *test.sh*. Just run it.

## Usage

In case you have the cluster in AWS:

```yaml
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: helm-deploy
      uses: energylinx/kube-deploy
      with:
        release: 'appname-sandbox'
        namespace: 'appname'
        chart: 'contrib/helm/'
        values_file: 'values.yml'
        atomic: 'yes'
        aws_access_key: 'XXXX'
        aws_secret_key: 'XXXX'
        region: 'eu-west-1'
        kube: 'kube-snb'
        replace: 'no'
        delete: 'no'
        set: ''
        wait: 'yes'
        timeout: '300'
```

Or in Azure:

```yaml
on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: helm-deploy
      uses: energylinx/kube-deploy
      with:
        release: 'appname-sandbox'
        namespace: 'appname'
        atomic: 'yes'
        azure_username: 'XXXX'
        azure_password: 'XXXX'
        azure_resource_group: 'XXXX'
        chart: 'contrib/helm/'
        values_file: 'values.yml'
        kube: 'kube-snb'
        replace: 'no'
        delete: 'no'
        set: ''
        wait: 'yes'
        timeout: '300'
```
