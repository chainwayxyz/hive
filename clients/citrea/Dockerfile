ARG baseimage=chainwayxyz/citrea
ARG tag=hive-latest

FROM $baseimage:$tag as builder

# Install script tools.
RUN apt-get update -y
RUN apt-get install -y bash curl jq

# Add genesis mapper script.
ADD genesis.json /genesis.json
ADD mapper.jq /mapper.jq

# Add the startup script.
ADD reth.sh /reth.sh
RUN chmod +x /reth.sh

# Add the enode URL retriever script.
ADD enode.sh /hive-bin/enode.sh
RUN chmod +x /hive-bin/enode.sh

# Create version.txt
RUN /app/target/release/citrea --version > /version.txt 2>&1 || echo "citrea-hive" > /version.txt

# Export the usual networking ports to allow outside access to the node.
EXPOSE 8545 8546 30303 30303/udp

# Run the startup script.
# ENTRYPOINT ["sh", "-c", "./publish_block.sh & ./sov-demo-rollup --genesis-type docker --rollup-config-path mock_dockerized_rollup_config.toml --sequencer-config-path mock_sequencer_config.toml"]