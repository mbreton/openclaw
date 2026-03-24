ARG OPENCLAW_VERSION=latest
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_VERSION}

USER root

# CA_CERT_B64: base64-encoded PEM of the proxy CA certificate.
# Pass at build time: docker build --build-arg CA_CERT_B64=$(base64 -w0 proxy-ca.crt) .
# If omitted, trust the CA at runtime via NODE_EXTRA_CA_CERTS instead (see docker-compose.yml).
ARG CA_CERT_B64=""
RUN if [ -n "${CA_CERT_B64}" ]; then \
      echo "${CA_CERT_B64}" | base64 -d > /usr/local/share/ca-certificates/proxy-ca.crt && \
      update-ca-certificates; \
    fi

USER node
