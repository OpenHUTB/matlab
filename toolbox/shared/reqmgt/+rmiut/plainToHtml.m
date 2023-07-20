function txt=plainToHtml(txt)












    txt=strrep(txt,'&','&amp;');
    txt=strrep(txt,'<','&lt;');
    txt=strrep(txt,'>','&gt;');
    txt=strrep(txt,newline,['<br/>',newline]);

end
