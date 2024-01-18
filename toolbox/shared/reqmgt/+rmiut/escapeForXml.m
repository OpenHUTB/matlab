function out=escapeForXml(in)

    step0=strrep(in,'&','&amp;');
    step1=strrep(step0,'<','&lt;');
    out=strrep(step1,'>','&gt;');

end
