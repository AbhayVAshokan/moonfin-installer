#!/bin/bash

if [ -z "$1" ]; then
    echo "Please pass the IP address of your Samsung TV as part of the commandline arguments for this script.";
		exit 1;
fi

TAG_URL="${2:-https://github.com/Moonfin-Client/Smart-TV/releases/latest}";

if [ -z "$2" ]; then
	FULL_TAG_URL=$(curl -sLI $TAG_URL | grep -i 'location:' | sed -e 's/^[Ll]ocation: //g' | tr -d '\r');

	# Check if FULL_TAG_URL is not empty and valid
	if [ -z "$FULL_TAG_URL" ]; then
		echo "Error: Could not fetch the latest tag URL from $TAG_URL"
		exit 1
	fi
 
	TAG=$(basename "$FULL_TAG_URL");
	echo "Tag URL not provided, using the latest available version: $TAG";
	echo "You can change it by passing tag URL as second argument for this script.";
else
	# Extract the tag name from the provided TAG_URL
	TAG=$(basename "$TAG_URL")
 
	# Check if TAG is not empty
	if [ -z "$TAG" ]; then
		echo "Error: Could not extract the tag from the provided URL $TAG_URL"
		echo "Please provide a URL to the full release, for example: https://github.com/Moonfin-Client/Smart-TV/releases/tag/v2.3.0"
  		echo "Otherwise, don't provide a URL and the latest version will be installed."
		exit 1
	fi
fi

echo "Using built-in working certificates from Jellyfin setup."

# Construct filename - add 'v' prefix if not already present
if [[ $TAG == v* ]]; then
    FILENAME="Moonfin-${TAG}.wgt"
else
    FILENAME="Moonfin-v${TAG}.wgt"
fi

DOWNLOAD_URL=$(echo https://github.com/Moonfin-Client/Smart-TV/releases/download/${TAG}/${FILENAME});

echo ""
echo ""
echo "	Thanks to the Moonfin team for providing Moonfin Smart TV builds!";
echo "	These builds can be found at https://github.com/Moonfin-Client/Smart-TV";
echo ""
echo "	Using Moonfin Tizen Build ${FILENAME}";
echo "	from release: $TAG";
echo ""
echo ""

TV_IP="$1";

echo "Attempting to connect to Samsung TV at IP address $TV_IP"
sdb connect $1

echo "Attempting to get the TV name..."
TV_NAME=$(sdb devices | grep -E 'device\s+\w+[-]?\w+' -o | sed 's/device//' - | xargs)

if [ -z "$TV_NAME" ]; then
    echo "We were unable to find the TV name.";
		exit 1;
fi
echo "Found TV name: $TV_NAME"

echo "Downloading Moonfin ${FILENAME} from release: $TAG"
wget -q --show-progress "$DOWNLOAD_URL"; echo ""

echo "Signing package using built-in working certificates"
tizen package -t wgt -s dev -- ${FILENAME}

echo "Attempting to install Moonfin ${FILENAME} from release: $TAG"
tizen install -n ${FILENAME} -t "$TV_NAME"
