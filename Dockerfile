FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    RETIPEDIA_HOME=/srv/pages/Retipedia \
    RETIPEDIA_DATA_DIR=/var/lib/rns-page-node \
    RETIPEDIA_ZIMS_DIR=/zims \
    RETICULUM_IDENTITY_DIR=/var/lib/rns-page-node/identity

RUN useradd --create-home --home-dir /home/app --shell /usr/sbin/nologin --uid 10001 app \
    && pip install --no-cache-dir "rns-page-node>=1.7.0" "libzim" "beautifulsoup4"

RUN python - <<'PY'
import tarfile
import urllib.request

url = "https://codeload.github.com/RFnexus/Retipedia/tar.gz/refs/heads/master"
out = "/tmp/retipedia.tar.gz"
urllib.request.urlretrieve(url, out)
with tarfile.open(out, "r:gz") as tf:
    tf.extractall("/tmp", filter="data")
PY

RUN mkdir -p /srv/pages /srv/files "$RETIPEDIA_DATA_DIR/retipedia" \
    && mv /tmp/Retipedia-master "$RETIPEDIA_HOME" \
    && rm -f /tmp/retipedia.tar.gz

COPY settings.py /tmp/settings.py
RUN cp /tmp/settings.py "$RETIPEDIA_HOME/settings.py" \
    && rm -f /tmp/settings.py \
    && rm -rf "$RETIPEDIA_HOME"/zims "$RETIPEDIA_HOME"/cache "$RETIPEDIA_HOME"/images \
    && mkdir -p "$RETIPEDIA_DATA_DIR"/retipedia/zims "$RETIPEDIA_DATA_DIR"/retipedia/cache "$RETIPEDIA_DATA_DIR"/retipedia/images \
    && ln -s "$RETIPEDIA_DATA_DIR"/retipedia/zims "$RETIPEDIA_HOME"/zims \
    && ln -s "$RETIPEDIA_DATA_DIR"/retipedia/cache "$RETIPEDIA_HOME"/cache \
    && ln -s "$RETIPEDIA_DATA_DIR"/retipedia/images "$RETIPEDIA_HOME"/images \
    && python3 "$RETIPEDIA_HOME/generate_meta.py" --fix-shebangs=/usr/local/bin/python3 \
    && chmod +x "$RETIPEDIA_HOME"/*.mu

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chown -R app:app /srv/pages /srv/files /var/lib/rns-page-node /usr/local/bin/docker-entrypoint.sh

USER app
WORKDIR /srv/pages

VOLUME ["/var/lib/rns-page-node", "/zims"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
