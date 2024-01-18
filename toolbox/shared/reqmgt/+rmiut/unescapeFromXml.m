function out=unescapeFromXml(in)
    step1=strrep(in,'&lt;','<');
    step2=strrep(step1,'&gt;','>');
    out=strrep(step2,'&amp;','&');
end
