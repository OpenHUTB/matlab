function nagctlr(type,err,mdlName)










    aObject={which(mdlName)};
    if isequal(lower(type),'error')
        message=sf('Private','clean_error_msg',err.message);
        msgids=err.identifier;
        sldiagviewer.reportError(message,'MessageId',msgids,'Component','HDL Verifier','Category','HDL Verifier','Objects',aObject);
    elseif isequal(lower(type),'warning')
        message=sf('Private','clean_error_msg',lastwarn);
        msgids=[];
        sldiagviewer.reportWarning(message,'MessageId',msgids,'Component','HDL Verifier','Category','HDL Verifier','Objects',aObject);
    else
        message=sf('Private','clean_error_msg',lastwarn);
        msgids=[];
        sldiagviewer.reportInfo(message,'MessageId',msgids,'Component','HDL Verifier','Category','HDL Verifier','Objects',aObject);
    end

