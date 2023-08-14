function[status,changelog]=synchronize(this,syncOptions)


    status='';
    changelog=[];





    mgr=slreq.app.MainManager.getInstance;
    eemgr=mgr.externalEditorManager;
    if~eemgr.detachExternalEditors('Slvnv:slreq:ExternalEditorInUseWhenUpdate')
        return;
    end

    doConfirmFileLocation=true;

    if nargin<2

        syncOptions=struct('ignoreWhiteSpace',true,'diagnosticsMode',false);
    elseif~isstruct(syncOptions)


        doConfirmFileLocation=syncOptions;
        syncOptions=struct('ignoreWhiteSpace',true,'diagnosticsMode',false);
    elseif isfield(syncOptions,'interactive')
        doConfirmFileLocation=syncOptions.interactive;
        syncOptions=rmfield(syncOptions,'interactive');
    end



    mgr.clearSelectedObjectsUponDeletion([],true);




    mgr.putToSleep();



    w=onCleanup(@()cleanup(this));





    dataReqSet=this.RequirementSet.dataModelObj;
    reqSetFilePath=dataReqSet.filepath;



    if~rmiut.isCompletePath(reqSetFilePath)
        error(message('Slvnv:slreq:RequirementSetNotSaved'))
    end













    externalDomainLabel=this.dataModelObj.domain;
    if doConfirmFileLocation&&slreq.uri.isBackedByFile(externalDomainLabel)


        storedUri=this.dataModelObj.artifactUri;
        artifactUri=slreq.uri.ResourcePathHandler.getFullPath(storedUri,reqSetFilePath);
        if isempty(artifactUri)

            artifactUri=slreq.import.docToReqSetMap(reqSetFilePath,storedUri);
            if isempty(artifactUri)

                artifactUri=slreq.uri.getShortNameExt(storedUri);
            end
        end


        derivedUri=artifactUri;
        artifactUri=slreq.uri.promptForFileLocation(artifactUri);
        if isempty(artifactUri)

            if isempty(derivedUri)

                error(message('Slvnv:slreq_import:ImportMissingFile',storedUri));
            else

                return;
            end
        end



        newStoredUri=slreq.uri.getPreferredPath(artifactUri,reqSetFilePath,storedUri);
        if~strcmp(newStoredUri,storedUri)



            dataReqSet.updateSrcArtifactUri(this.dataModelObj,artifactUri);
        end






        resolvedUri=slreq.uri.ResourcePathHandler.getFullPath(newStoredUri,reqSetFilePath);
        if isempty(resolvedUri)
            docFolder=fileparts(artifactUri);
            addpath(docFolder);
            clp=onCleanup(@()rmpath(docFolder));



        end
    end


    try

        this.detach();


        [statusData,changelog]=slreq.internal.synchronize(this.dataModelObj,syncOptions);


        this.resyncAfterDetach();


        reqRoot=this.parent.parent;
        status=statusData.message;
        reqRoot.showSuggestion(statusData.id,status);

        domain='linktype_rmi_slreq';
        reqData=slreq.data.ReqData.getInstance();

        dataLinkSet=reqData.getLinkSet(reqSetFilePath,domain);


        if~isempty(dataLinkSet)
            reqData.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('LinkSet Loaded',dataLinkSet));
            slreq.internal.Events.getInstance.notify('LinkSetLoaded',slreq.internal.LinkSetEventData(dataLinkSet));
        else
            this.view.update();
        end

    catch ex
        status=ex.message;







        badAttributeName=checkForInvalidAttributeName(ex);
        if~isempty(badAttributeName)
            if slreq.internal.promptToRemoveStaleAttributeOption(this.dataModelObj,badAttributeName,ex.message)
                msgbox(getString(message('Slvnv:slreq_import:AttributeRemoved',badAttributeName)),...
                getString(message('Slvnv:slreq_import:ImportOptionsUpdateSuccessful')),'modal');
            else
                msgbox(getString(message('Slvnv:slreq_import:UnableToUpdateAttribute',badAttributeName,this.dataModelObj.artifactUri)),...
                getString(message('Slvnv:slreq_import:UnableToSyncronize')),'modal');
            end
        else
            errordlg(ex.message,...
            getString(message('Slvnv:slreq_import:UnableToSyncronize')),'modal');
        end
        this.resyncAfterDetach();
        this.view.update();
    end
end

function badName=checkForInvalidAttributeName(ex)
    badName='';
    if strcmp(ex.identifier,'Slvnv:reqmgt:InvalidAttributeName')
        matched=regexp(ex.message,'"(.+)"','tokens');
        if~isempty(matched)
            badName=matched{1}{1};
        end
    end
end

function cleanup(dasReq)

    mgr=slreq.app.MainManager.getInstance;
    mgr.wakeUp();
    dasReq.setDisplayIcon();
end
