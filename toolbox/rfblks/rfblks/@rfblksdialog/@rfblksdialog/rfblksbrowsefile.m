function rfblksbrowsefile(source,dialog)





    try
        filename=getfile(rfdata.data);
    catch browseException
        errordlg(browseException.message);
        return
    end
    if isempty(filename)||isequal(filename,0)
        return
    end





    setWidgetValue(dialog,'File',filename);

    source.File=filename;
    setWidgetValue(dialog,'File',filename);



