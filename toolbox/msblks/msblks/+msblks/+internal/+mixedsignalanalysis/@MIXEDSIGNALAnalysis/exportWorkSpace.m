function hDoc=exportWorkSpace(obj)

    sw=StringWriter;

    addcr(sw,'% --------------------------------------------------')
    addcr(sw,'% MATLAB script to build Mixed Signal Analyzer plots')
    addcr(sw,'% --------------------------------------------------')

    if nargout<1
        matlab.desktop.editor.newDocument(sw.string);
    else
        hDoc=matlab.desktop.editor.newDocument(sw.string);
    end

end
