function ret=isWebGraphicsDisabled

    ret=~isempty(getenv('DISABLE_WEB_GRAPHICS'));