function extent=get_text_width(labelStr,hgObj)




    set(hgObj,'String',labelStr);
    ext=get(hgObj,'Extent');
    extent=ext(3);