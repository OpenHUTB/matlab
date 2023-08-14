function SlreqImportDlg_Import_callback(this,dlg)






    sourceDoc=this.srcDoc;
    [~,srcName,srcExt]=fileparts(sourceDoc);

    [destReqSetName,multiReqSets]=this.makeReqSetNameForSrcDoc();



    if~isempty(this.destReqSet)&&~multiReqSets
        destReqSetName=this.destReqSet;
    end
    destReqSetName=strrep(destReqSetName,'$DocumentName$',srcName);
    [~,reqSetName]=fileparts(destReqSetName);


    if this.srcType==5

        reqSet=[];
    else
        reqSet=slreq.data.ReqData.getInstance.getReqSet(reqSetName);
        if isempty(reqSet)



            reqSet=slreq.das.ReqRoot.createAndSaveReqSet(destReqSetName);
            if isempty(reqSet)



                return;
            end
        end
    end

    shortDestName=slreq.uri.getShortNameExt(destReqSetName);
    rmiut.progressBarFcn('set',0.1,getString(message('Slvnv:slreq_import:ImportingTo',shortDestName)));
    clb=onCleanup(@()rmiut.progressBarFcn('delete'));
    slreq.uri.ResourcePathHandler.setInteractive(true);
    clp=onCleanup(@()slreq.uri.ResourcePathHandler.setInteractive(false));
    try
        doProxy=this.importMode||this.srcType>3;
        switch this.srcType
        case 1
            optStruct=this.msOptionsStruct();
            optStruct.preImportFcn=this.PreImportFcn;
            optStruct.postImportFcn=this.PostImportFcn;
            count=slreq.import(sourceDoc,'ReqSet',destReqSetName,'AsReference',doProxy,'options',optStruct);
        case 2
            optStruct=this.msOptionsStruct();
            optStruct.mapping=this.mappingOptions;
            optStruct.preImportFcn=this.PreImportFcn;
            optStruct.postImportFcn=this.PostImportFcn;
            count=slreq.import(sourceDoc,'ReqSet',destReqSetName,'AsReference',doProxy,'options',optStruct);

        case 3
            this.attributeMap=this.reqIFPanel.mappingFile;
            asMultiple=this.reqIFPanel.getAsMutlipleReqSets();
            singleSpec=this.reqIFPanel.getSelectedSpec();
            importLinks=this.reqIFPanel.getImportLinks();


            count=slreq.import(sourceDoc,'ReqSet',destReqSetName,'AsReference',doProxy,'asMultiple',asMultiple,'singleSpec',singleSpec,'importLinks',importLinks,'preImportFcn',this.PreImportFcn,'postImportFcn',this.PostImportFcn);
        case 4




            doorsOptions=this.doorsOptionalArgs();
            doorsOptions.preImportFcn=this.PreImportFcn;
            doorsOptions.postImportFcn=this.PostImportFcn;
            count=slreq.import('linktype_rmi_doors','ReqSet',destReqSetName,...
            'AsReference',doProxy,'options',doorsOptions);




            srcName=strtok(srcName);


            reqData=slreq.data.ReqData.getInstance();
            if isempty(this.mappingOptions)


                this.populateDoorsMapping([]);
            end
            reqData.addMapping(reqSet,this.mappingOptions);

        case 5
            [count,reqSet]=this.SlreqImportDlg_dngImport_callback(dlg);

        otherwise


            count=0;
        end
        rmiut.progressBarFcn('set',0.9,getString(message('Slvnv:slreq_import:ImportingTo',shortDestName)));

    catch ex
        switch this.srcType
        case 1
            msgId='Slvnv:slreq_import:FailedToImportFromWord';
        case 2
            msgId='Slvnv:slreq_import:FailedToImportFromExcel';
        otherwise
            msgId='';
        end
        if~isempty(msgId)
            msgToDisplay=getString(message(msgId,ex.message,sourceDoc));
            errordlg(msgToDisplay,getString(message('Slvnv:slreq:Error')));
        else
            errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
        end
        count=-1;
    end

    updateDetectionMgr=slreq.dataexchange.UpdateDetectionManager.getInstance();
    updateDetectionMgr.checkUpdatesForAllArtifacts();

    if this.srcType<4
        sourceLabel=[srcName,srcExt];
    else
        sourceLabel=strtok(this.srcDoc);
    end

    if count>0






        reqSet.save();





        if slreq.app.MainManager.isEditorVisible()
            slreq.showDocInReqSet(reqSetName,sourceLabel,this.subDoc);
        end


        if doProxy


            slreq.import.ui.ImportDlg.warnIfNonUniqueCustomIds(reqSet,sourceLabel,this.subDoc);
        end


        slreq.import.ui.dlg_mgr('clear');

    else

        if~this.isReqsetContext

            if~isempty(reqSet)
                emptyReqSetFile=reqSet.filepath;
                reqSet.discard();
                delete(emptyReqSetFile);
            end
        end
        if count<0

        else
            errordlg(getString(message('Slvnv:slreq_import:NothingImportedFrom',sourceLabel)),...
            'ERROR','modal');
        end
    end
end

