# Kube deploy actions

This actions is designed for Energlinx and it downloaded kube configuration from AWS and deploys local or remote helm chart.

## Testing

If *entrypoint.sh* is run in environment where *TEST* variable contains 'yes' it just echo's the helm and aws commands.

Testing is implemented in *test.sh*. Just run it.

## Usage

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
        aws_access_key: 'XXXX'
        aws_secret_key: 'XXXX'
        kube: 'kube-snb'
        replace: 'no'
        delete: 'no'
        set: ''
        wait: 'yes'
        timeout: '300'
        region: 'eu-west-1'
```
