function str=unescapeHtml(str)
    str=strrep(str,'&amp;','&');
    str=strrep(str,'&apos;','''');
    str=strrep(str,'&gt;','>');
    str=strrep(str,'&lt;','<');
end