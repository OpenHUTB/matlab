function updateOSLCRequirements(this,serverLoginInfo,projUri,moduleUriOrQueryBase,queryString,dataImportNode)






    progressInfo=dataImportNode.customId;
    if isempty(progressInfo)




        if length(queryString)>40
            progressInfo=urlencode([queryString(1:20),'..',queryString(end-15:end)]);
        else
            progressInfo=urlencode(queryString);
        end
    end
    rmiut.progressBarFcn('set',0.1,getString(message('Slvnv:slreq_import:DngUpdatingReferences',progressInfo)));


    this.fetchOSLCProjectTypes(serverLoginInfo,projUri);






    dataReqs=dataImportNode.children;
    count=length(dataReqs);
    for i=count:-1:1
        dataReq=dataReqs(i);
        if mod(i,5)==0
            progress=(count-i)/count/2;
            rmiut.progressBarFcn('set',0.1+progress,getString(message('Slvnv:slreq_import:DngUpdatingReferences',progressInfo)));
        end
        this.removeRequirement(dataReq);
    end


    dataReqSet=dataImportNode.getReqSet;
    mfReqSet=this.getModelObj(dataReqSet);
    mfRootItem=this.getModelObj(dataImportNode);



    mfReqSet.modifiedOn=slreq.utils.getDateTime(datetime(),'Write');

    rmiut.progressBarFcn('set',0.7,getString(message('Slvnv:slreq_import:DngUpdatingReferences',progressInfo)));
    if isempty(queryString)
        this.repository.fetchModuleContents(mfReqSet,mfRootItem,moduleUriOrQueryBase);
        topNodeInfo=struct('type','module','name',dataImportNode.summary);
    else

        queryBaseWithConfig=oslc.matlab.DngClient.appendContextParam(moduleUriOrQueryBase);
        this.repository.fetchRequirements(mfReqSet,mfRootItem,queryBaseWithConfig,queryString);
        topNodeInfo=struct('type','query','name',dataImportNode.summary);
    end
    rmiut.progressBarFcn('set',0.9,getString(message('Slvnv:slreq_import:DngUpdatingReferences',progressInfo)));


    mfRootItem.modifiedOn=slreq.utils.getDateTime(datetime(),'Write');
    mfRootItem.synchronizedOn=mfRootItem.modifiedOn;
    mfReqSet.modifiedOn=mfRootItem.modifiedOn;


    this.refreshLinkSetsByRegistration(dataReqSet.name);


    oslc.internal.postImportCallback(dataImportNode,topNodeInfo);

    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',dataImportNode));
    rmiut.progressBarFcn('delete');
end