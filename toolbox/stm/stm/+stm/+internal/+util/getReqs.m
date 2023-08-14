function reqDesc=getReqs(testfile,uuid,testName)


    reqDesc=repmat(struct('url','','description',''),0,1);

    origRmiNavOption=rmipref('ReportNavUseMatlab',false);
    oc=onCleanup(@()rmipref('ReportNavUseMatlab',origRmiNavOption));

    portNum=connector.port;
    if(portNum~=31415)

        currentCustomSettings=rmipref('CustomSettings');
        originalCurrentCustomSettings=currentCustomSettings;
        if isfield(currentCustomSettings,'allowedPorts')
            if~any(currentCustomSettings.allowedPorts==portNum)
                currentCustomSettings.allowedPorts=[currentCustomSettings.allowedPorts,portNum];
            end
        else
            currentCustomSettings.allowedPorts=portNum;
        end
        rmipref('CustomSettings',currentCustomSettings);
        h=onCleanup(@()rmipref('CustomSettings',originalCurrentCustomSettings));
    end

    [~,~,fileExt]=fileparts(testfile);
    if strcmpi(fileExt,'.m')
        reqs=rmitm.getReqs(testfile,testName);
    else
        reqs=rmitm.getReqs(testfile,uuid);
    end
    if isempty(reqs)
        return;
    end

    reqDesc=struct('url','',...
    'description',{reqs.description},...
    'docurl','',...
    'doc',{reqs.doc},...
    'rid',{reqs.id},...
    'reqsys',{reqs.reqsys}).';

    mask=strlength({reqs.doc})~=0;
    docurls=arrayfun(@(req)rmi.reqToUrl(req,testfile),...
    reqs(mask),'Uniform',false);
    [reqDesc(mask).docurl]=docurls{:};
    [reqDesc.url]=reqDesc.docurl;
    mask=strlength({reqDesc.url})==0;
    if any(mask)
        [reqDesc(mask).url]=reqDesc(mask).doc;
    end
end
