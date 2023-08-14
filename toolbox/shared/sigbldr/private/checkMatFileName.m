function[pathstr,name,ext]=checkMatFileName(matFileName)





    msg='';


    try
        [pathstr,name,ext]=fileparts(matFileName);
    catch matFileNameError
        errordlg(getString(message('Sigbldr:sigbldr:ExportError',matFileNameError.message)));
    end

    if isempty(name)
        msg=getString(message('sigbldr_ui:exportMatFile:InvalidFileName'));
    end

    if~strcmp(ext,{'.mat',''})
        msg=getString(message('sigbldr_ui:exportMatFile:NotMatFile'));
    end

    if~isempty(msg)
        ME=MException('sigbldr_api:signalbuilder:invalidSignalOrGroupIndex','''%s''',msg);
        throw(ME);
    end

end
