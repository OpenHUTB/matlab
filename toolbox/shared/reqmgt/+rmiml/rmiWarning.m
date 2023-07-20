function result=rmiWarning(id,varargin)




    result='success';

    dlgTitle=getString(message('Slvnv:rmiml:RequirementsTraceabilityWarning'));

    switch id
    case char(com.mathworks.toolbox.simulink.slvnv.RmiUtils.WARN_UNSAVED_DESTINATION)
        messageStr=getString(message('Slvnv:rmiml:CopyPasteToUnsaved',varargin{1}));
    otherwise
        messageStr=['UNSUPPORTED_WARNING: ',id];
    end

    warndlg(messageStr,dlgTitle);

end
