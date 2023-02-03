FROM ubuntu:focal

# Default Ports
EXPOSE 8080
EXPOSE 44000

# Send logging to stdout and stderr
ENV RUST_LOG=info
ENV DEBIAN_FRONTEND=noninteractive
ENV PYRSIA_BOOTDNS=boot.pyrsia.link

RUN apt-get update; \
    apt-get -y install ca-certificates wget gnupg2 jq curl dnsutils git gcc protobuf-compiler; \
    curl --fail https://pyrsia.io/install.sh -o ./install.sh; \
    chmod 755 ./install.sh; \
    ./install.sh;

# Get Rust; NOTE: using sh for better compatibility with other base images
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Add .cargo/bin to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /buildnode

RUN git clone https://github.com/tiainen/pyrsia_build_pipeline_prototype.git .
RUN cargo build

RUN mkdir -p /root/.config/pyrsia-cli; \
    echo "host = '${PYRSIA_BOOTDNS}'" > /root/.config/pyrsia-cli/default-config.toml; \
    echo "port = '80'" >> /root/.config/pyrsia-cli/default-config.toml; \
    echo "disk_allocated = '100 GB'" >> /root/.config/pyrsia-cli/default-config.toml

ENTRYPOINT [ "/build/target/debug/_build", "--host", "0.0.0.0" ]
