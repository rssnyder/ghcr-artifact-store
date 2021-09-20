# ghcr-artifact-store

Use github container registry (or any container registry) to store artifacts for your github actions workflows

## setup

You will need access to publish to github packages from your actions workflow. You can use the default `GITHUB_TOKEN` or a PAT.

The environment for your workflow will also need to have docker installed, which is included with `ubuntu-latest`.

You should run the action from the directory with your artifact to be uploaded using `working-directory`.

## usage

```yaml
inputs:
  method:
    description: 'GET or PUT. Defaults to GET.'
    required: false
    default: GET
  source:
    description: 'Name of the file to act upon'
    required: true
  tag:
    description: 'Tag for image when pushed to ghcr. Defaults to latest.'
    required: false
    default: artifacts
  image:
    description: 'Image to store. Defaults to ghcr.io/<owner>/<repo>.'
    required: false
    default: ''
  registry_user:
    description: 'Username for pushing to ghcr. Defaults to the user who trigered the workflow.'
    required: false
    default: ''
  registry_token:
    description: 'Token for pushing to ghcr. Defaults to the built in GITHUB_TOKEN.'
    required: false
    default: ''
```

### put

```yaml
- uses: rssnyder/ghcr-artifact-store
  with:
    method: PUT
    artifact: state.json
    token: ${{ secrets.GITHUB_TOKEN }}
```

### get

```yaml
- uses: rssnyder/ghcr-artifact-store
  with:
    artifact: state.json
    token: ${{ secrets.GITHUB_TOKEN }}
```

## example

See an example of storing terraform state using this method [here](https://github.com/rssnyder/isengard/blob/master/.github/workflows/terraform.yml#L28).

## bootstraping

To bootstrap an inital image for your repository, grab a github PAT with `packages:write` and set `GITHUB_TOKEN` to it and do the following steps locally:

```shell
# Login
> echo $GITHUB_TOKEN | docker login ghcr.io -u <owner> --password-stdin

# Use busybox as source
> docker pull busybox
> docker tag busybox ghcr.io/<owner>/<repo>:artifacts

# Push to ghcr
> docker push ghcr.io/<owner>/<repo>:artifacts
```

Why `busybox`? I wanted to use a popular image that people could "trust" that was also as minimal as possible.

```shell
> docker pull busybox
> docker images busybox --format "{{.Repository}}:{{.Tag}} -> {{.Size}}"
busybox:latest -> 1.24MB
```

## security

By default packages are private when first created and you must change them to public. If you are using this on a repository that is already publishing a public image to ghcr then **do not store sensitive information in your artifacts**.

In addition, you should tag your references to this composite to a version you have audited.

## use locally

```shell
GITHUB_TOKEN=<pat> GITHUB_ACTOR=<username> GITHUB_REPOSITORY=<owner>/<repo> METHOD="PUT" sh action.sh state.json
GITHUB_TOKEN=<pat> GITHUB_ACTOR=<username> GITHUB_REPOSITORY=<owner>/<repo> sh action.sh state.json
```
