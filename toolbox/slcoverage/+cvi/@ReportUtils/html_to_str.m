function out=html_to_str(in)




    out=strrep(in,'&apos;','''');
    out=strrep(out,'&quot;','"');
    out=strrep(out,'&lt;','<');
    out=strrep(out,'&gt;','>');
    out=strrep(out,'&amp;','&');