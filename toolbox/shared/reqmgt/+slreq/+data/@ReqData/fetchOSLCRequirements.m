function dataReqSet=fetchOSLCRequirements(this,serverLoginInfoStruct,projectInfo,topNodeInfo,destReqSet)









    projectInfo.serverName=serverLoginInfoStruct.server;


    [mfReqSet,mfRootItem]=this.createOSLCReqSet(destReqSet,'DNG',projectInfo,topNodeInfo);
    dataReqSet=this.wrap(mfReqSet);
    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('ReqSet Loaded',dataReqSet));


    if strcmp(topNodeInfo.type,'module')



        this.repository.fetchModuleContents(mfReqSet,mfRootItem,topNodeInfo.uri);
    else

        queryBase=oslc.matlab.DngClient.appendContextParam(projectInfo.queryBase);
        this.repository.fetchRequirements(mfReqSet,mfRootItem,queryBase,topNodeInfo.params);
    end


    topNode=this.wrap(mfRootItem);


    oslc.internal.postImportCallback(topNode,topNodeInfo);

    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',topNode));


    this.refreshLinkSetsByRegistration(mfReqSet.name);
end
