function errMsg=dmiSelectBlock_(DOORSId,objString)%#ok<INUSL>





    if rmisl.isSidString(objString)


        errMsg=navigateToSid(objString);
    else
        errMsg=rmisl.navDoorsToSl(objString);
    end

    if~isempty(errMsg)
        errordlg(errMsg,getString(message('Slvnv:reqmgt:doorsMatlabInterfaceError')));
    end
end

function errMsg=navigateToSid(sid)
    errMsg='';
    [mdlName,nSid]=strtok(sid,':');
    try
        rmiobjnavigate(mdlName,nSid);
    catch ex
        errMsg=ex.message;
    end
end


