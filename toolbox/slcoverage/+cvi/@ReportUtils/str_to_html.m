function out=str_to_html(in)




    out=strrep(in,'&','&amp;');
    out=strrep(out,'<','&lt;');
    out=strrep(out,'>','&gt;');
    out=strrep(out,'''','&apos;');
    out=strrep(out,'"','&quot;');