# k8s-toolbox

A docker image with some tools to manage Kubernetes in AWS:

- kubectl
- helm
- eksctl
- aws cli v2

## Running locally


Set up your [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) in the `~/.aws/credentials` file. 

Example contents:

```ini
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Note:** 

The UID and GID in the image are set to 1000. If your UID and GID are different and you want to mount your credentials file as a volume in the container, you need to rebuild the image passing your correct values as build arguments. 

Example:

```sh
docker build --tag yourname/k8s-toolbox --build-arg PUID=1001 --build-arg PGID=1001 .
```

### Run the container:

To run the container with your AWS credentials and k8s config locally:

```sh
docker run --rm -it -v $(pwd):/app/k8s -v ~/.aws:/app/.aws:ro -v ~/.kube:/app/.kube:ro --env AWS_PROFILE andreswebs/k8s-toolbox
```

Note that this will mount the current directory inside the container under `/app/k8s`.

## Authors

**Andre Silva**

## License

This project is licensed under the [Unlicense](UNLICENSE.md).