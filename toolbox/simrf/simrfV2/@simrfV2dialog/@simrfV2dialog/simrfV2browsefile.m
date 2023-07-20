function simrfV2browsefile(source,dialog)





    try
        [filename,pathname]=uigetfile({...
        '*.*p;*.*P;','Touchstone files (*.snp,*.ynp,*.znp)';...
        '*.*','All Files (*.*)'},'Select a Touchstone data file');
    catch browseException
        errordlg(browseException.message);
        return
    end
    if isequal(filename,0)
        return
    end
    filename=fullfile(pathname,filename);
    setWidgetValue(dialog,'File',filename);

    source.File=filename;
    setWidgetValue(dialog,'File',filename);



