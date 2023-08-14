function out=rtwhtmlescape(txt)






    out=strrep(txt,'&','&amp;');
    out=strrep(out,'<','&lt;');
    out=strrep(out,'>','&gt;');
