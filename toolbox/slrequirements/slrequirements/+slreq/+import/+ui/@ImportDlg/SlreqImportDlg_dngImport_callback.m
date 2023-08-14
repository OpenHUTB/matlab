function[count,dataReqSet,refs]=SlreqImportDlg_dngImport_callback(this,~)






    projectInfo.name=this.srcDoc;
    [projectInfo.uri,projectInfo.serviceUri]=this.getProjectUri(this.serverCatalog,this.srcDoc);
    reqData=slreq.data.ReqData.getInstance();
    serverLoginInfoStruct=struct('server',this.serverName,'username',this.serverUser,'passcode',this.serverPass);
    projectInfo.queryBase=reqData.fetchOSLCQueryBaseURI(serverLoginInfoStruct,projectInfo.serviceUri);


    if this.connectionMode==0

        topNodeInfo.type='module';
        topNodeInfo.name=this.subDoc;
        [topNodeInfo.uri,topNodeInfo.id]=this.getModuleUri(this.modulesInfo,this.subDoc);
        topNodeInfo.params='';
    else
        topNodeInfo.type='query';
        topNodeInfo.name=getString(message('Slvnv:slreq_import:DngQueryResult'));
        topNodeInfo.uri='';
        topNodeInfo.id='';
        topNodeInfo.params=this.queryString;
        slreq.import.QueryHistoryMgr.update(this.srcDoc,this.queryString);
    end


    dataReqSet=reqData.fetchOSLCRequirements(serverLoginInfoStruct,projectInfo,topNodeInfo,this.destReqSet);

    reqSetName=slreq.uri.getShortNameExt(this.destReqSet);
    rmiut.progressBarFcn('set',0.7,getString(message('Slvnv:slreq_import:ImportingTo',reqSetName)));

    [~,refs]=dataReqSet.getItems();
    count=numel(refs);
end

