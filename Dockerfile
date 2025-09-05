# Dockerfile
FROM ruby:3.3.2-slim

ENV BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RAILS_ENV=development \
    LANG=C.UTF-8 \
    TZ=UTC

RUN apt-get update -y && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      git \
      curl \
      ca-certificates \
      pkg-config \
      vim \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash app
WORKDIR /app

# アプリ全体をコピー or 開発はボリュームマウント頼りなら entrypoint だけでもOK
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

EXPOSE 3000
CMD ["bash", "-lc", "bin/rails s -b 0.0.0.0 -p 3000"]
