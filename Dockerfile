FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    RETIPEDIA_HOME=/srv/pages/Retipedia \
    RETIPEDIA_DATA_DIR=/var/lib/rns-page-node \
    RETIPEDIA_ZIMS_DIR=/zims \
    RETICULUM_IDENTITY_DIR=/var/lib/rns-page-node/identity

RUN useradd --create-home --home-dir /home/app --shell /usr/sbin/nologin --uid 10001 app \
    && pip install --no-cache-dir "rns-page-node==1.7.0" "libzim==3.13.0" "beautifulsoup4==4.15.0"

RUN python - <<'PY'
import os
import tarfile
import urllib.request

ref = "2920e6ae300e40fe551745819fc8c856cbc9ac2f"
url = f"https://codeload.github.com/RFnexus/Retipedia/tar.gz/{ref}"
out = "/tmp/retipedia.tar.gz"
extract_dir = "/tmp/retipedia-src"
urllib.request.urlretrieve(url, out)
os.makedirs(extract_dir, exist_ok=True)
real_extract_dir = os.path.realpath(extract_dir) + os.sep
with tarfile.open(out, "r:gz") as tf:
    for member in tf.getmembers():
        member_path = os.path.realpath(os.path.join(extract_dir, member.name))
        if not member_path.startswith(real_extract_dir):
            raise RuntimeError(f"unsafe archive path: {member.name}")
        if member.issym() or member.islnk():
            link_target = os.path.realpath(
                os.path.join(os.path.dirname(member_path), member.linkname)
            )
            if not link_target.startswith(real_extract_dir):
                raise RuntimeError(f"unsafe archive link: {member.name}")
    tf.extractall(extract_dir, filter="data")
PY

RUN mkdir -p /srv/pages /srv/files "$RETIPEDIA_DATA_DIR/retipedia" \
    && mv /tmp/retipedia-src/Retipedia-* "$RETIPEDIA_HOME" \
    && rm -rf /tmp/retipedia-src \
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
