FROM vitalets/tizen-webos-sdk

# Copy working certificate files to exact locations from Jellyfin setup
COPY author.p12 /home/developer/author.p12
COPY profiles.xml /home/developer/tizen-studio-data/profile/profiles.xml
COPY entrypoint.sh ./

# Create directory structure for distributor certificate
RUN mkdir -p /home/developer/tizen-studio/tools/certificate-generator/certificates/distributor/

# Copy distributor certificate to correct path
COPY distributor.p12 /home/developer/tizen-studio/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.p12

# jq for quickly parsing the TV name from the API endpoint
RUN apt update && apt install jq -y && rm -rf /var/lib/apt/lists/* && rm -rf /var/cache/apt/*

# Set proper permissions for all files
RUN chown developer:developer entrypoint.sh && chmod +x entrypoint.sh
RUN chown developer:developer /home/developer/author.p12
RUN chown developer:developer /home/developer/tizen-studio/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.p12
RUN chown developer:developer /home/developer/tizen-studio-data/profile/profiles.xml

ENTRYPOINT [ "/home/developer/entrypoint.sh" ]