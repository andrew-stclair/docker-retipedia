import os


def _bool(name, default=False):
    value = os.getenv(name)
    if value is None:
        return default
    return value.strip().lower() in {"1", "true", "yes", "on"}


def _int(name, default):
    value = os.getenv(name)
    if value is None:
        return default
    try:
        return int(value)
    except ValueError:
        return default


root_folder = os.getenv("RETIPEDIA_ROOT_FOLDER", "Retipedia")
zims_dir = os.getenv("RETIPEDIA_ZIMS_DIR", "/zims")
archive_path = os.getenv("RETIPEDIA_ARCHIVE_PATH", "")
archive_type = os.getenv("RETIPEDIA_ARCHIVE_TYPE", "wikipedia")
chunk_size = _int("RETIPEDIA_CHUNK_SIZE", 4096)
text_layout = os.getenv("RETIPEDIA_TEXT_LAYOUT", "wide")
text_width = _int("RETIPEDIA_TEXT_WIDTH", 72)
page_cache = _int("RETIPEDIA_PAGE_CACHE", 604800)
images = _bool("RETIPEDIA_IMAGES", False)
accent_color = os.getenv("RETIPEDIA_ACCENT_COLOR", "default")
ascii_art_enabled = _bool("RETIPEDIA_ASCII_ART", True)
node_title = os.getenv("RETIPEDIA_NODE_TITLE", "🬧 The NomadNet Encyclopedia")
lxmf_address = os.getenv("RETIPEDIA_LXMF_ADDRESS", "") or False
