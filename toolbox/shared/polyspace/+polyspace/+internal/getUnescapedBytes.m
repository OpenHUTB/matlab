function bytes=getUnescapedBytes(chars)
    validateattributes(chars,{'char'},{'row'});
    FILESYSTEM_UNESCAPE_BYTES=4;
    bytes=filesystem_mex(FILESYSTEM_UNESCAPE_BYTES,chars);


