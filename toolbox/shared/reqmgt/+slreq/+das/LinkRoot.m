classdef LinkRoot<slreq.das.BaseObject




    properties
        reqData;
        linkDataChangeListener;
        slTestFileListerners={};
    end

    methods
        function this=LinkRoot(view)
            this@slreq.das.BaseObject();

            this.view=view;
            this.reqData=slreq.data.ReqData.getInstance();
            this.linkDataChangeListener=this.reqData.addlistener('LinkDataChange',@this.onLinkDataChange);
            if dig.isProductInstalled('Simulink Test')&&contains(path,['toolbox',filesep,'stm',filesep,'stm'])
                this.slTestFileListerners{1}=sltest.internal.Events.getInstance.addlistener('TestFileOpened',@this.onSLTestFileOpened);
                this.slTestFileListerners{2}=sltest.internal.Events.getInstance.addlistener('TestFileClosed',@this.onSLTestFileClosed);
            end
            this.syncWithRepository();
            this.notifyViewChange(true);
        end

        function delete(this)


            delete(this.linkDataChangeListener);
            this.linkDataChangeListener=[];

            for n=1:length(this.slTestFileListerners)
                delete(this.slTestFileListerners{n});
            end

            this.slTestFileListerners={};
        end

        function linkSetDasObj=addLinkSet(this,artifact,domain)
            this.linkDataChangeListener.Enabled=false;
            linkSet=this.reqData.createLinkSet(artifact,domain);
            this.linkDataChangeListener.Enabled=true;
            linkSetDasObj=slreq.das.LinkSet(linkSet,this,this.view,this.linkDataChangeListener);
            this.addChildObject(linkSetDasObj);
            this.notifyViewChange(true);
        end


        function onSLTestFileOpened(this,~,testFileOpenedEvent)


            testFilePath=char(testFileOpenedEvent.FilePath);
            if~slreq.hasData(testFilePath)
                slreq.utils.loadLinkSet(testFilePath);

            else





                mgr=slreq.app.MainManager.getInstance;
                mgr.update;
            end

        end

        function onSLTestFileClosed(this,~,testFileClosedEvent)

            mgr=slreq.app.MainManager.getInstance;
            mgr.update;

        end

        function onLinkDataChange(this,~,eventInfo)
            slreq.utils.assertValid(this);

            if~isa(eventInfo,'slreq.data.LinkDataChangeEvent')


                return;
            end
            localDataRefreshed=false;
            switch eventInfo.type
            case 'LinkSet Profile Outdated'
                linkSetInfo=eventInfo.eventObj;
                hasWarningAlready=hasWarningForLinkSet(this.children,linkSetInfo.linkSetFile);
                if~hasWarningAlready
                    dasLinkSet=slreq.das.LinkSetNotLoaded(this,...
                    this.view,...
                    this.linkDataChangeListener);
                    dasLinkSet.Label=linkSetInfo.name;
                    dasLinkSet.Filepath=linkSetInfo.linkSetFile;
                    dasLinkSet.Artifact=linkSetInfo.artifact;

                    this.addChildObject(dasLinkSet);
                end
            case{'LinkSet Created','LinkSet Loaded'}
                dataLinkSet=eventInfo.eventObj;

                dasLinkSet=dataLinkSet.getDasObject();
                if isempty(dasLinkSet)
                    dasLinkSet=slreq.das.LinkSet(dataLinkSet,...
                    this,...
                    this.view,...
                    this.linkDataChangeListener);
                    this.addChildObject(dasLinkSet);
                else
                    dasLinkSet.traverseLinks();
                end







                if strcmpi(dataLinkSet.domain,'linktype_rmi_simulink')
                    [~,modelName]=fileparts(dataLinkSet.artifact);
                    if rmisl.isSimulinkModelLoaded(modelName)
                        bmgr=this.view.badgeManager;
                        if slreq.utils.isInPerspective(modelName,true)



                            modelH=get_param(modelName,'Handle');
                            spmgr=slreq.app.MainManager.getInstance.spreadsheetManager;
                            spObjs=spmgr.getAllSpreadSheetObjects(modelH);
                            for spObj=spObjs












                                spObj.refreshDisplayedInfo();
                            end





                            bmgr.refreshBadges(modelName);

                        end







                        if~isempty(bmgr)
                            bmgr.refreshBadgeForLinkedDiagram(modelName);
                        end
                    end
                end

                localDataRefreshed=true;

                mgr=slreq.app.MainManager.getInstance;
                allViewers=mgr.getAllViewers;
                if strcmp(eventInfo.type,'LinkSet Created')



                    if mgr.isChangeInformationEnabled(allViewers)
                        ctmgr=mgr.changeTracker;
                        ctmgr.refreshLinkSet(dasLinkSet);
                    end
                else
                    if~mgr.isAnalysisDeferred
                        if mgr.isChangeInformationEnabled(allViewers)





                            ctmgr=mgr.changeTracker;
                            ctmgr.refresh();
                        end
                        needRefreshImpl=mgr.isImplementationStatusEnabled(allViewers);
                        needRefreshVerif=mgr.isVerificationStatusEnabled(allViewers);
                        slreq.analysis.BaseRollupAnalysis.refreshRollupStatusForLinks(dataLinkSet,needRefreshImpl,needRefreshVerif);
                    else
                        mgr.showDeferredAnalysisNotification();
                    end
                end
            case 'Before Discarding LinkSet'
                dataLinkSet=eventInfo.eventObj;
                if strcmp(dataLinkSet.domain,'linktype_rmi_simulink')&&dig.isProductInstalled('Simulink')


                    [~,modelName]=fileparts(dataLinkSet.artifact);
                    if bdIsLoaded(modelName)



                        modelH=get_param(modelName,'Handle');
                        this.view.markupManager.hideMarkupsAndConnectorsForModel(modelH);







                        mgr=slreq.app.MainManager.getInstance;
                        spDataMgr=mgr.spreadSheetDataManager;
                        spData=spDataMgr.getSpreadSheetDataObject(modelH);
                        if~isempty(spData)
                            spData.clearDasLinkSet();
                        end
                    end
                end
                dasLinkSet=dataLinkSet.getDasObject();
                if~isempty(dasLinkSet)
                    dasLinkSet.removeGhostIfNeeded();
                    index=this.findObjectIndex(dasLinkSet);


                    this.view.clearSelectedObjectsUponDeletion(dasLinkSet);

                    dasLinkSet.discardAll();

                    if index>0




                        this.children(index)=[];
                    end
                end





                mgr=slreq.app.MainManager.getInstance;
                allViewers=mgr.getAllViewers;



                rememberInvolvedReqsForLinkset('clear');
                rememberInvolvedReqsForLinkset('set',dataLinkSet,allViewers);

                return;

            case{'LinkSetDirtied','LinkSetUndirtied'}

                dataLinkSet=eventInfo.eventObj;
                dasLinkSet=dataLinkSet.getDasObject();

                if~isempty(dasLinkSet)
                    mgr=slreq.app.MainManager.getInstance;
                    mgr.refreshUI(dasLinkSet);
                end


                return;

            case{'ReqSetRegUpdated'}
                dataLinkSet=eventInfo.eventObj;


                if strcmp(dataLinkSet.domain,'linktype_rmi_simulink')
                    sourceArtifact=dataLinkSet.artifact;
                    [~,mdlName]=fileparts(sourceArtifact);
                    if get_param(mdlName,'ReqPerspectiveActive')


                        mgr=slreq.app.MainManager.getInstance();
                        mgr.spreadsheetManager.updateDisplayedReqSets(mdlName);
                        mgr.spreadsheetManager.refreshUI();
                    end
                end
                return;

            case 'Link Added'
                dataLink=eventInfo.eventObj;
                dataLinkSet=dataLink.getLinkSet();
                dasLinkSet=dataLinkSet.getDasObject();

                if isempty(dasLinkSet)
                    dasLinkSet=slreq.das.LinkSet(dataLinkSet,...
                    this,...
                    this.view,...
                    this.linkDataChangeListener);
                    this.addChildObject(dasLinkSet);
                end
                dasLinkSet.addChild(dataLink);
                this.view.spreadsheetManager.updateOnLinkCreation(dataLink);

                mgr=slreq.app.MainManager.getInstance;
                allViewers=mgr.getAllViewers;
                localDataRefreshed=true;
                dasLinkObj=dataLink.getDasObject;
                if~isempty(dasLinkObj)
                    if mgr.isChangeInformationEnabled(allViewers)




                        ctmgr=mgr.changeTracker;
                        ctmgr.refreshLink(dasLinkObj);
                    end

                    needRefreshImpl=mgr.isImplementationStatusEnabled(allViewers);
                    needRefreshVerif=mgr.isVerificationStatusEnabled(allViewers);
                    slreq.analysis.BaseRollupAnalysis.refreshRollupStatusForLinks(dataLink,needRefreshImpl,needRefreshVerif);
                end

            case 'Link Deleted'
                dataLink=eventInfo.eventObj;


                dasLink=dataLink.getDasObject();
                if isempty(dasLink)
                    return;
                end



                mgr=slreq.app.MainManager.getInstance;
                allViewers=mgr.getAllViewers;
                localDataRefreshed=true;

                dataLinkSet=dataLink.getLinkSet();
                dasLinkSet=dataLinkSet.getDasObject();
                dasLinkSet.removeGhostIfNeeded();
                dasLinkSet.removeChildObject(dasLink,false);


                if mgr.isChangeInformationEnabled(allViewers)


                    ctmgr=mgr.changeTracker;
                    ctmgr.refreshLinkSet(dasLinkSet);
                end

                dataReqs=rememberInvolvedReqsForLinkset('get');

                rememberInvolvedReqsForLinkset('clear');





                slreq.analysis.BaseRollupAnalysis.refreshImplementationStatusForReqs(dataReqs.implement);


                slreq.analysis.BaseRollupAnalysis.refreshVerificationStatusForReqs(dataReqs.verify);

            case 'BeforeDeleteLink'
                dataLink=eventInfo.eventObj;
                dasLink=dataLink.getDasObject();
                if~isempty(dasLink)
                    dasLink.destroyConnector(true);
                    dasLink.destroyConnector(false);
                end


                this.view.clearSelectedObjectsUponDeletion(dasLink);

                mgr=slreq.app.MainManager.getInstance;
                allViewers=mgr.getAllViewers;
                rememberInvolvedReqsForLinkset('clear');
                rememberInvolvedReqsForLinkset('set',dataLink,allViewers);
                localDataRefreshed=true;
            case 'Set Prop Update'
                dataObj=eventInfo.eventObj;
                dasObj=dataObj.getDasObject();
                needToNotify=false;

                if isa(dasObj,'slreq.das.Link')
                    connector=dasObj.Connector;
                    if~isempty(connector)
                        if strcmpi(eventInfo.PropName,'source')


                            isDiagram=connector.isDiagram;
                            dasObj.destroyConnector(isDiagram);
                            dasObj.showConnector(isDiagram);
                        else
                            connector.update();
                        end
                    end

                    diagramConnector=dasObj.DiagramConnector;
                    if~isempty(diagramConnector)
                        diagramConnector.update();
                    end

                    mgr=slreq.app.MainManager.getInstance;
                    allViewers=mgr.getAllViewers;
                    localDataRefreshed=true;

                    [affectImp,affectVer]=dataObj.doesChangeImpactRollupStatus(eventInfo);

                    needRefreshImpl=affectImp&&mgr.isImplementationStatusEnabled(allViewers);
                    needRefreshVerif=affectVer&&mgr.isVerificationStatusEnabled(allViewers);

                    needToNotify=(affectImp||affectVer)&&slreq.analysis.BaseRollupAnalysis.refreshRollupStatusForLinks(dataObj,needRefreshImpl,needRefreshVerif);

                    if contains(eventInfo.PropName,{'source','destination'})...
                        &&mgr.isChangeInformationEnabled(allViewers)


                        ctmgr=mgr.changeTracker;
                        ctmgr.refreshLink(dasObj);
                        needToNotify=true;
                    end
                end

                if needToNotify



                    this.notifyViewChange(localDataRefreshed);
                elseif~isempty(dasObj)



                    mgr=slreq.app.MainManager.getInstance;
                    mgr.refreshUI(dasObj);
                    dasObj.updatePropertyInspector(eventInfo);
                end
                return;
            case 'LinkSet Discard Completed'
                eventData=eventInfo.eventObj;





                if strcmpi(eventData.domain,'linktype_rmi_simulink')
                    [~,modelName]=fileparts(eventData.artifact);
                    bmgr=this.view.badgeManager;
                    bmgr.refreshBadgeForLinkedDiagram(modelName)
                end
                localDataRefreshed=true;


                mgr=slreq.app.MainManager.getInstance;
                allViewers=mgr.getAllViewers;
                if mgr.isChangeInformationEnabled(allViewers)


                    ctmgr=mgr.changeTracker;
                    ctmgr.refresh();
                end

                dataReqs=rememberInvolvedReqsForLinkset('get');
                rememberInvolvedReqsForLinkset('clear');
                if mgr.isImplementationStatusEnabled(allViewers)





                    slreq.analysis.BaseRollupAnalysis.refreshImplementationStatusForReqs(dataReqs.implement);
                end

                if mgr.isVerificationStatusEnabled(allViewers)






                    slreq.analysis.BaseRollupAnalysis.refreshVerificationStatusForReqs(dataReqs.verify)
                end

            case 'CustomAttributeModified'

                modInfo=eventInfo.eventObj;
                if~strcmp(modInfo.prevName,modInfo.newName)

                    if~isempty(this.view.requirementsEditor)
                        this.view.requirementsEditor.updateColumnOnCustomAttributeNameChange(modInfo.prevName,modInfo.newName);
                    end
                    if~isempty(this.view.spreadsheetManager)
                        this.view.spreadsheetManager.updateColumnOnCustomAttributeNameChange(modInfo.prevName,modInfo.newName);
                    end
                end



                localDataRefreshed=true;
            case 'CustomAttributeRemoved'

                modInfo=eventInfo.eventObj;
                if~isempty(this.view.requirementsEditor)
                    this.view.requirementsEditor.updateColumnOnCustomAttributeRemoval(modInfo.removedName);
                end
                if~isempty(this.view.spreadsheetManager)
                    this.view.spreadsheetManager.updateColumnOnCustomAttributeRemoval(modInfo.removedName);
                end



                localDataRefreshed=true;
            end
            this.notifyViewChange(localDataRefreshed);
        end


        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.folder;
        end

        function label=getDisplayLabel(this)%#ok<MANU>
            label='Link Set files';
        end

        function prop=getProperty(this,propName)
            prop='';
            if strcmp(propName,'Identifier')
                prop=this.getDisplayLabel();
            end
        end

        function dlgstruct=getDialogSchema(this)
            dlgstruct=slreq.gui.OnRampDialog(this);
        end

        function attrs=getAvailableAttributes(this)


            builtInAttr=slreq.utils.getBuiltinAttributeList('link');

            customAttr=slreq.utils.getCustomAttributeList(this.children);
            attrs=[builtInAttr,customAttr];
        end

        function count=ensureDasTrees(this)


            count=0;
            dataLinkSets=this.reqData.getLoadedLinkSets();
            for i=1:numel(dataLinkSets)
                dataLinkSet=dataLinkSets(i);
                if isempty(dataLinkSet.getDasObject())
                    eventData=struct('type','LinkSet Loaded','eventObj',dataLinkSet);
                    this.onLinkDataChange('',eventData);
                    count=count+1;
                end
            end
        end
    end

    methods(Access=private)
        function syncWithRepository(this)
            this.children=slreq.das.LinkSet.empty();

            linkSets=this.reqData.getLoadedLinkSets();
            for i=1:numel(linkSets)
                this.addChildObject(slreq.das.LinkSet(linkSets(i),...
                this,this.view,this.linkDataChangeListener));
            end
        end
    end
end



function out=rememberInvolvedReqsForLinkset(action,dataLinkOrLinkSet,allViewers)








    persistent dataReqs
    switch action
    case 'clear'
        clear dataReqs
    case 'set'
        mgr=slreq.app.MainManager.getInstance;
        needRefreshImpl=mgr.isImplementationStatusEnabled(allViewers);
        needefreshVerif=mgr.isVerificationStatusEnabled(allViewers);
        [dataReqsForImpl,dataReqsForVeri]=slreq.analysis.BaseRollupAnalysis.getInvolvedReqs(dataLinkOrLinkSet,needRefreshImpl,needefreshVerif);
        dataReqs.implement=dataReqsForImpl;
        dataReqs.verify=dataReqsForVeri;
    case 'get'
        out=dataReqs;
    end
end

function tf=hasWarningForLinkSet(children,linkset)

    tf=any(arrayfun(@(x)strcmp(x.Filepath,linkset),children));
end

