FROM node:22-slim

# Toolchain for compiling native modules (better-sqlite3) when no prebuilt binary
# matches this image's platform/ABI. Cleaned up in the same layer to keep the image small.
RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 make g++ gosu \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm@9

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod=false

COPY tsconfig.json ./
COPY bin/ ./bin/
COPY src/ ./src/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN pnpm build

# Create data directory for sync state, owned by the non-root runtime user
RUN chmod +x /usr/local/bin/docker-entrypoint \
  && mkdir -p /data \
  && chown -R node:node /data

ENTRYPOINT ["docker-entrypoint"]
CMD ["node", "dist/index.js"]
