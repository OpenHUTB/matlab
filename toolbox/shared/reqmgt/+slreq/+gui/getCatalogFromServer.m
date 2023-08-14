function[catalog,loginInfo]=getCatalogFromServer(servername)








    catalog=[];

    maxRetry=3;
    retry=0;
    reqData=slreq.data.ReqData.getInstance();
    while retry<maxRetry
        if retry>1

            servername='';
            oslc.server([]);
            oslc.user([]);
        end
        if nargin==0||isempty(servername)
            servername=oslc.trimServerUrl(oslc.server());
        end
        username=oslc.user();
        passcode=oslc.passcode(username,retry>0);
        if isempty(passcode)
            error(message('Slvnv:oslc:PasswordNotSupplied'));
        end
        loginInfo=struct('server',servername,'username',username,'passcode',passcode);
        try

            catalog=reqData.getCatalogFromOslcServer(loginInfo);
            return;
        catch ex
            if strcmp(ex.identifier,'Slvnv:oslc:FailedLogin')
                retry=retry+1;
            else
                throwAsCaller(ex);
            end
        end
    end
    if retry==maxRetry


        loginInfo.server='';
        oslc.server([]);
        msgText=getString(message('Slvnv:oslc:FailedLoginPleaseVerify'));
        msgTitle=getString(message('Slvnv:oslc:FailedLogin'));
        errordlg(msgText,msgTitle);
    end
end
