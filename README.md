# Install Moonfin for Samsung TV

This project makes it easy to install [Moonfin for Samsung TV](https://github.com/Moonfin-Client/Smart-TV) with a single pre-configured docker container.

Moonfin is a Jellyfin client for Samsung Smart TVs, providing an enhanced viewing experience with additional features and optimizations.

**Note:** This project is forked from <https://github.com/Georift/install-jellyfin-tizen> and rebuilt specifically for Moonfin.

## Getting Started

- Install [Docker](https://www.docker.com/get-started/)
  - Enable any necessary [Virtualization](https://support.microsoft.com/en-us/windows/enable-virtualization-on-windows-11-pcs-c5578302-6e43-4b4b-a449-8ced115f58e1) features.

- Ensure you are connected to the same network as the TV.

## Configure Samsung TV

#### Place TV in Developer Mode

- On the TV, open the "Smart Hub".
- Select the "Apps" panel.
- Press the "123" button (or if your remote doesn't have this button, long press the Home button) before typing "12345" with the on-screen keyboard.
- Toggle the `Developer` button to `On`.
- Enter the `Host PC IP` address of the computer you're running this container on. [Need help?](docs/troubleshooting.md)

#### Uninstall Existing Moonfin/Jellyfin Installations, If Required

Follow the [Samsung uninstall instructions](https://www.samsung.com/in/support/tv-audio-video/how-to-uninstall-an-app-on-samsung-smart-tv/)

#### Find IP Address

- Exact instructions will vary with the model of TV. In general you can find the TV's IP address in Settings under Networking or About. Plenty of guides are available with a quick search, however for brevity a short guide with pictures can be found [here](https://www.techsolutions.support.com/how-to/how-to-check-connection-on-samsung-smart-tv-10925).

- Make a note of the IP address as it will be needed later.

## Install Moonfin

#### Installation

- Run the command below from the cloned repository directory, replacing the first argument with the IP of your Samsung TV
  - If you just want to install the default build, do not put anything after the IP address.
  - (Optional) You can provide preferred [Moonfin release](https://github.com/Moonfin-Client/Smart-TV/releases) tag URL as second argument. By default, latest version is used. This is useful if you want to install a specific Moonfin version.
  - If you do not want to use either of these options and just install the default build, do not put anything after the IP address.

```bash
docker run --rm abhayvashokan/moonfin-installer <samsung tv ip> [tag url]
```

Examples:

```bash
# Install latest version
docker run --rm abhayvashokan/moonfin-installer 192.168.0.10

# Install specific version
docker run --rm abhayvashokan/moonfin-installer 192.168.0.10 "https://github.com/Moonfin-Client/Smart-TV/releases/tag/v2.3.0"
```

### Validating Success

#### Common Errors

- library initialization failed - unable to allocate file descriptor table - out of memory

  Add `--ulimit nofile=1024:65536` to the `docker run` command:

  ```bash
  docker run --ulimit nofile=1024:65536 --rm abhayvashokan/moonfin-installer <samsung tv ip> [tag url]
  ```

- install failed[118, -11], reason: Author certificate not match :

  Uninstall the Moonfin application from your Samsung TV, and run the installation again.

#### Success

If everything went well, you should see docker output something like the following

```txt
Installed the package: Id(AprZAARz4r.Moonfin)
Tizen application is successfully installed.
Total time: 00:00:12.205
```

At this point you can find Moonfin on your TV by navigating to Apps -> Downloaded (scroll down), there you'll find Moonfin.

## Supported Platforms

At the moment, these steps should work on any amd64 based system. Platforms
like the Raspberry Pi, which run ARM chips, are not yet supported.

### Additional Required Commands: ARM (MacOS M Chips and higher)

Use the `--platform linux/amd64"` argument on the original command. This should look something like this:

```bash
docker run --rm --platform linux/amd64 abhayvashokan/moonfin-installer <samsung tv ip> [tag url]`
```

- install failed[118, -12], reason: Check certificate error : :Invalid certificate chain with certificate in signature.

  Recent TV models require the installation packages to be signed with a custom certificate for your specific TV.

  See [official documentation](https://developer.samsung.com/smarttv/develop/getting-started/setting-up-sdk/creating-certificates.html) on creating your certificate and use the custom certificate arguments.

## Credits

This project is possible thanks to these projects:

- [Moonfin Smart TV](https://github.com/Moonfin-Client/Smart-TV) for providing the Moonfin client builds
- [jellyfin-tizen](https://github.com/jellyfin/jellyfin-tizen) for the original foundation
- [vitalets/docker-tizen-webos-sdk](https://github.com/vitalets/docker-tizen-webos-sdk) for a docker container preinstalled with the Tizen SDK
- [Georift/install-jellyfin-tizen](https://github.com/Georift/install-jellyfin-tizen)

## Similar Projects

Here are some similar projects we've been told of, links are provided here without any endorsement for their quality.

- [PatrickSt1991/Samsung-Jellyfin-Installer](https://github.com/PatrickSt1991/Samsung-Jellyfin-Installer):
  - GUI based installer rather than Docker

Feel free to raise a PR with any additional features.

## Development

### Building the Docker Image

If you want to build the Docker image locally instead of using the pre-built image:

```bash
# Clone the repository
git clone https://github.com/AbhayVAshokan/moonfin-installer.git
cd moonfin-installer

# Build the Docker image
docker build --platform linux/amd64 -t moonfin-installer .

# Use your locally built image
docker run --rm moonfin-installer <samsung tv ip> [tag url]
```

### Setting up Samsung Certificates for Local Development

When building the Docker image locally, you'll need to provide Samsung certificates. The pre-built image includes working certificates, but you may need custom certificates for specific TV models.

1. **Create Samsung Certificates**: Follow the [official Samsung documentation](https://developer.samsung.com/smarttv/develop/getting-started/setting-up-sdk/creating-certificates.html) to create your certificates.

2. **Place Certificate Files**: After creating your certificates, place the following files in the project root directory:
   - `author.p12` - Your author certificate
   - `distributor.p12` - Your distributor certificate
   - `profiles.xml` - Your Tizen profile configuration

3. **File Requirements**:
   - These files are automatically ignored by Git (see `.gitignore`) as they contain private keys.
   - The certificate files should match the names expected by the Dockerfile.
   - The certificates are built into the Docker image and used automatically - no password parameter needed.

4. **Build and Run**: Once the files are in place, you can build and run as shown above.

**Note**: The pre-built image `abhayvashokan/moonfin-installer` includes working certificates that should work with most TVs. You only need custom certificates if you encounter certificate-related errors during installation.
