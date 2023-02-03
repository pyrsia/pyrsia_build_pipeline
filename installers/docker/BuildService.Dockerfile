FROM ubuntu:focal

# Default Ports
EXPOSE 8080
EXPOSE 44000

# Send logging to stdout and stderr
ENV RUST_LOG=debug
ENV PYRSIA_BOOTDNS=boot.pyrsia.link

WORKDIR /buildnode

COPY target/release/pyrsia_build .

RUN mkdir -p /root/.config/pyrsia-cli; \
    echo "host = '${PYRSIA_BOOTDNS}'" > /root/.config/pyrsia-cli/default-config.toml; \
    echo "port = '80'" >> /root/.config/pyrsia-cli/default-config.toml; \
    echo "disk_allocated = '100 GB'" >> /root/.config/pyrsia-cli/default-config.toml

ENTRYPOINT [ "pyrsia_build", "--host", "0.0.0.0" ]
