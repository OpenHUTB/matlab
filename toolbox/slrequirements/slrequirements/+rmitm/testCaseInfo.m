function[navcmd,dispStr,iconFile]=testCaseInfo(destination,locationId)




    if nargin==1

        [fPath,remainder]=strtok(destination,'|');
        locationId=remainder(2:end);
    else


        fPath=destination;
    end

    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_testmgr');
    dispStr=adapter.getLinkLabel(fPath,locationId);




    if strcmp(rmipref('ModelPathReference'),'none')
        fPath=slreq.uri.getShortNameExt(fPath);
    end
    navcmd=adapter.getClickActionCommandString(fPath,locationId,'');


    if nargout>2
        iconFile=rmiut.getMwIcon();
    end
end

