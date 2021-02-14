# Custom Debian ISO builder

This repository defines a docker image that allows to build custom live Debian based ISOs.

It is based on the great instructions provided by Will Halley: https://willhaley.com/blog/custom-debian-live-environment/

## Build a custom image

To build your custom image you will need to create the following files:

- `configure.sh`: This script will be end at the end of the image configuration and allows you to add custom configuration
- `packages`: List the packages to be added to your ISO. At least one package is expected
- `repositories`: Define additional deb repositories. It can be an empty file.
- `repositories-keys`: Add keyservers and key ids for any additional deb repository you may add to `repositories` file 

You can see examples in `example` directory.

This files are expected to be made available to the container as a volume mount to `/root/files` directory

```
docker run -t --rm -v $(pwd):/root/files aitorpazos/create-debian-iso
```

If everything goes well, the output ISO file will be located in the `$(pwd)` folder.
