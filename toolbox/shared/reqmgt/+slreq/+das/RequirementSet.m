classdef RequirementSet<slreq.das.ReqLinkBase&slreq.das.RollupStatus





    properties(Access={?slreq.gui.CustomAttributeRegistryPanel,?slreq.gui.CustomAttributeRegistryEditDialog})


        selectedCustomAttribute;
    end

    properties(Access={?slreq.das.ReqRoot,?slreq.das.ReqSetInSL})
eventListener
    end

    properties(Dependent)
Name
Filepath
Dirty
IdPrefix
IdDelimiter
Description
MATLABVersion
PreSaveFcn
PostLoadFcn
    end

    properties(Access={?slreq.das.Markup,?slreq.app.MarkupManager})



        MarkupReqSIDMap;
    end

    properties(Access=private)
        descendantCreated;
    end

    methods
        function this=RequirementSet(dataModelObj,parent,view,eventListener)
            this@slreq.das.ReqLinkBase(dataModelObj,parent);
            this.childrenCreated=false;
            this.descendantCreated=false;

            this.view=view;
            this.eventListener=eventListener;
            this.MarkupReqSIDMap=containers.Map('KeyType','Char','ValueType','logical');
        end

        function name=getDisplayName(this,propName)

            name=this.getDisplayNameForBuiltin(propName);
        end

        function fileName=getSlxFileName(this)
            fileName='';
            if~this.isBackedBySlx()
                return
            end
            slxFile=this.dataModelObj.parent;
            [~,fileName]=fileparts(slxFile);
        end

        function update(this)
            function dasReq=createDasReqObj(parent,dataObj)
                dasReq=slreq.das.Requirement();
                dasReq.postConstructorProcess(dataObj,parent,this.view,this.eventListener);
                parent.addChildObject(dasReq);
            end

            this.doUpdate(@createDasReqObj);
        end

        function ch=getChildren(this,~)
            if~this.childrenCreated
                this.childrenCreated=true;
                if isempty(this.children)
                    rootReqs=this.dataModelObj.children;
                    view=this.view;
                    eventListener=this.eventListener;
                    switch view.viewManager.getCurrentView.displayMode
                    case slreq.gui.View.FULL
                        for i=1:numel(rootReqs)
                            reqDasObj=slreq.das.Requirement();
                            reqDasObj.postConstructorProcess(rootReqs(i),this,view,eventListener)
                            this.addChildObject(reqDasObj);
                        end
                    case slreq.gui.View.FULL_FLAT
                        apiSet=slreq.utils.dataToApiObject(this.dataModelObj);
                        dataReqs=apiSet.find('type','Requirement','_returnType','dataObject');
                        for i=1:length(dataReqs)
                            reqDasObj=slreq.das.Requirement();
                            reqDasObj.postConstructorProcess(dataReqs(i),this,view,eventListener)
                            this.addChildObject(reqDasObj);
                        end
                    case slreq.gui.View.FILTERED_ONLY
                        for i=1:numel(rootReqs)
                            if rootReqs(i).isFilteredParent()||rootReqs(i).isFilteredIn()
                                reqDasObj=slreq.das.Requirement();
                                reqDasObj.postConstructorProcess(rootReqs(i),this,view,eventListener)
                                this.addChildObject(reqDasObj);
                            end
                        end
                    case slreq.gui.View.FLAT_FILTERED_ONLY
                        reqs=view.viewManager.getCurrentView.reqQuery.getQueryResult;
                        for i=1:numel(reqs)
                            reqDasObj=slreq.das.Requirement();
                            reqDasObj.childrenCreated=true;
                            reqDasObj.postConstructorProcess(reqs(i),this,view,eventListener)
                            this.addChildObject(reqDasObj);
                        end
                    end
                end
            end

            ch=this.children;
        end


        function createChildren(this)
            if~this.descendantCreated
                children=this.getChildren();
                for i=1:numel(children)
                    children(i).createChildren;
                end
            end
            this.descendantCreated=true;
        end


        function ch=getHierarchicalChildren(this)
            ch=this.getChildren(this);
        end

        function reqDasObj=addRequirement(this)

            this.eventListener.Enabled=false;
            reqObj=this.dataModelObj.addRequirement();
            this.eventListener.Enabled=true;

            reqDasObj=slreq.das.Requirement();
            reqDasObj.postConstructorProcess(reqObj,this,this.view,this.eventListener);

            if~isempty(this.children)&&this.children(end).dataModelObj.isJustification







                this.insertChildObjectAt(reqDasObj,length(this.children));
            else
                this.addChildObject(reqDasObj);
            end



            mgr=slreq.app.MainManager.getInstance;
            mgr.updateRollupStatusLocally(reqObj);

            this.notifyViewChange(true);
        end

        function justifObj=addChildJustification(this)
            justif=this.dataModelObj.addJustification(this,'child');
            justifObj=justif.getDasObject();
        end



















        function statusData=exportToPreviousReqSet(this,saveType)%#ok<INUSD>


            statusData=struct('success','','message','','id','');




            [matlabVersions,productVersions]=slreq.utils.VersionHandler.getPreviousVersions();
            productMatlabVersions=strcat(productVersions,'/',matlabVersions);
            filenameExtensions=repmat({'.slreqx'},size(productMatlabVersions));
            versions=[filenameExtensions,productMatlabVersions];

            [filename,pathname,filterIdx]=uiputfile(versions,...
            getString(message('Slvnv:slreq:SelectThePathToExportRequirementSetFile',this.Name)),...
            this.Filepath);
            if isequal(filename,0)
                statusData.success=false;
                return;
            end




            asVersionString=versions{filterIdx,2};

            [~,remainder]=strtok(asVersionString,'/');
            asVersion=remainder(2:end);

            v2FilePath=fullfile(pathname,filename);

            if~this.isValidFileNameForSave(v2FilePath)
                statusData.success=false;
                return;
            end


            appmgr=slreq.app.MainManager.getInstance();
            appmgr.notify('SleepUI');





            this.dataModelObj.save();
            v1FilePath=this.dataModelObj.filepath;


            this.dataModelObj.save(v2FilePath,asVersion);




            this.dataModelObj.updateIncomingLinks();


            this.dataModelObj.discard();


            appmgr.callbackHandler.loadReqSet(v1FilePath);


            appmgr.notify('WakeUI');







            statusData.success=true;
            statusData.id='Slvnv:slreq:ExportToPreviousCompleted';
            statusData.message=getString(message(statusData.id,v2FilePath));
        end


        function exportToReqIF(this,importNode)
            if nargin<2
                importNode=[];
            end

            if~isempty(importNode)
                dataRootReq=importNode.dataModelObj;
            else
                dataRootReq=slreq.data.Requirement.empty;
            end

            dlgSrc=slreq.gui.ExportToReqIFDialog(this.dataModelObj,dataRootReq);
            DAStudio.Dialog(dlgSrc);
        end








        function isValidFileName=isValidFileNameForSave(this,filepath)

            isValidFileName=false;

            [~,shortName]=fileparts(filepath);

            reqData=slreq.data.ReqData.getInstance;
            if reqData.isReservedReqSetName(shortName)
                errordlg(getString(message('Slvnv:slreq:RequirementSetNameReserved',shortName)),...
                getString(message('Slvnv:slreq:Error')),'modal');
                return;
            end

            loadedReqSet=reqData.getReqSet(shortName);
            if~isempty(loadedReqSet)
                errordlg(getString(message('Slvnv:slreq:RequirementSetAlreadyLoaded',shortName)),...
                getString(message('Slvnv:slreq:Error')),'modal');
                return;
            end

            if exist(filepath,'file')==2

                reply=questdlg(...
                getString(message('Slvnv:slreq:SavingRequirementSetQuestDlg',shortName)),...
                getString(message('Slvnv:slreq:SavingRequirementSet')),...
                getString(message('Slvnv:slreq:Yes')),...
                getString(message('Slvnv:slreq:Cancel')),...
                getString(message('Slvnv:slreq:Yes')));
                if isempty(reply)||strcmp(reply,getString(message('Slvnv:slreq:Cancel')))

                    return;
                end
            end


            isValidFileName=true;
        end

        function saveRequirementSet(this,saveType)

            if nargin<2

                if exist(this.Filepath,'file')==2
                    saveType='Overwrite';
                else
                    saveType='New';
                end
            end

            if this.isBackedBySlx()&&~strcmp(saveType,'SaveAs')
                fileName=this.getSlxFileName();
                mdlHandle=get_param(fileName,'handle');
                SLM3I.saveBlockDiagram(mdlHandle);
                return;
            end

            switch saveType
            case 'New'



                [filename,pathname]=uiputfile('*.slreqx',...
                getString(message('Slvnv:slreq:SelectThePathToSaveRequirementSetFile',this.Name)),...
                this.Filepath);
                if isequal(filename,0)
                    return;
                end
                filepath=fullfile(pathname,filename);
                this.dataModelObj.save(filepath);
                this.dataModelObj.updateIncomingLinks();
            case 'Overwrite'

                this.dataModelObj.save();
            case 'SaveAs'
                oldName=this.Name;

                [filename,pathname]=uiputfile('*.slreqx',...
                getString(message('Slvnv:slreq:SelectThePathToSaveRequirementSetFile',this.Name)),this.Name);
                if isequal(filename,0)
                    return;
                end
                filepath=fullfile(pathname,filename);

                isRename=~strcmp(filepath,this.Filepath);

                if~this.isValidFileNameForSave(filepath)
                    return;
                end


                this.dataModelObj.save(filepath);

                if isRename&&this.dataModelObj.hasIncomingLinks()



                    reply=questdlg({...
                    getString(message('Slvnv:slreq:UpdateIncomingLinksInfo',oldName)),...
                    getString(message('Slvnv:slreq:UpdateIncomingLinksQuest'))},...
                    getString(message('Slvnv:slreq:UpdateIncomingLinksTitle',oldName)),...
                    getString(message('Slvnv:slreq:Yes')),getString(message('Slvnv:slreq:No')),getString(message('Slvnv:slreq:Yes')));
                    if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:slreq:Yes')))

                        this.dataModelObj.updateIncomingLinks();
                    else

                        this.dataModelObj.disconnectIncomingLinks();
                    end
                end
            otherwise

            end

            this.notifyViewChange(true);
        end

        function dirty=get.Dirty(this)
            dirty=this.dataModelObj.dirty;
        end

        function name=get.Name(this)
            name=this.dataModelObj.name;
        end

        function set.Name(this,value)
            this.dataModelObj.name=value;
        end

        function name=get.Filepath(this)
            name=this.dataModelObj.filepath;
        end

        function set.Filepath(this,value)
            this.dataModelObj.filepath=value;
        end

        function name=get.IdPrefix(this)
            name=this.dataModelObj.idPrefix;
        end

        function set.IdPrefix(this,value)
            this.dataModelObj.idPrefix=value;
        end

        function name=get.IdDelimiter(this)
            name=this.dataModelObj.idDelimiter;
        end

        function set.IdDelimiter(this,value)
            this.dataModelObj.idDelimiter=value;
        end

        function name=get.Description(this)
            name=this.dataModelObj.description;
        end

        function set.Description(this,value)
            this.dataModelObj.description=value;
        end

        function value=get.MATLABVersion(this)
            value=this.dataModelObj.MATLABVersion;
        end


        function discard(this)


            this.dataModelObj.discard();



        end

        function status=getStatus(this,name)
            status=this.dataModelObj.status.(name);
        end

        function status=getSelfStatus(this,name)
            status=this.dataModelObj.selfStatus.(name);
        end

        function updateImportNodeIcons(this)
            dasTopNodes=this.children;
            for n=1:length(dasTopNodes)
                if dasTopNodes(n).dataModelObj.external
                    dasTopNodes(n).setDisplayIcon();
                end
            end
        end


        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.reqSet;
        end

        function label=getDisplayLabel(this)
            if this.Dirty
                label=[this.dataModelObj.name,'*'];
            else
                label=this.dataModelObj.name;
            end
        end

        function propValue=getPropValue(this,propName)
            propValue='';

            switch propName
            case 'Index'
                if this.Dirty
                    propValue=[this.dataModelObj.name,'*'];
                else
                    propValue=this.dataModelObj.name;
                end
            case 'Description'
                propValue=this.Description;
            case 'IdPrefix'
                propValue=this.IdPrefix;
            case 'IdDelimiter'
                propValue=this.IdDelimiter;
            case 'Implemented'
                propValue='';
            case 'Verified'
                propValue='';
            otherwise

                assert(false);





            end
        end


        function[bIsValid]=isValidProperty(this,propName)%#ok<INUSL>
            bIsValid=false;
            switch propName
            case 'Index'
                bIsValid=true;
            case 'Description'
                bIsValid=true;
            case 'IdPrefix'
                bIsValid=true;
            case 'IdDelimiter'
                bIsValid=true;
            case 'Implemented'
                bIsValid=true;
            case 'Verified'
                bIsValid=true;

            otherwise


            end
        end

        function setPropValue(this,propName,propValue)
            switch propName
            case 'Description'
                this.Description=propValue;
            otherwise
                error('Illegal setPropValue() call for %s in slreq.das.RequirementSet',propName);
            end
            mgr=slreq.app.MainManager.getInstance;
            mgr.refreshUI(this);
            this.view.getCurrentView.updateToolbar();
        end

        function tf=isDropAllowed(this)%#ok<MANU>
            tf=true;
        end

        function importDocument(this)

            this.eventListener.Enabled=false;
            this.dataModelObj.importDocument();
            this.eventListener.Enabled=true;
        end

        function createReferences(this)

            this.eventListener.Enabled=false;
            this.dataModelObj.createReferences();
            this.eventListener.Enabled=true;
        end

        function tf=isBackedBySlx(this)
            tf=~isempty(this.dataModelObj.parent);
        end
        function tf=isBackingModelLocked(this)
            tf=false;
            fileName=this.getSlxFileName();
            if isempty(fileName)||~dig.isProductInstalled('Simulink')||(~bdIsLoaded(fileName))
                return
            end
            lockstatus=get_param(fileName,'Lock');
            if strcmp(lockstatus,'on')
                tf=true;
            end
        end

        function items=getContextMenuItems(this,caller)
            reqData=slreq.data.ReqData.getInstance();
            cntxtMenuBuilder=slreq.gui.ContextMenuBuilder(caller);

            template=struct('name','','tag','','callback','','accel','','enabled','on');
            addReq=template;
            addReq.name=getString(message('Slvnv:slreq:AddRequirement'));
            addReq.tag='RequirementSet:AddRequirement';
            addReq.callback='slreq.das.RequirementSet.onAddRequirement()';
            addReq.enabled=bool2OnOff(~isBackedBySlx(this));
            paste=template;
            paste.name=getString(message('Slvnv:slreq:Paste'));
            paste.tag='RequirementSet:Paste';
            if~ishandle(caller)
                paste.accel='Ctrl+v';
            end

            paste.callback='slreq.das.RequirementSet.onPasteItem';

            if~reqData.hasCripboardItem()
                paste.enabled='off';
            end

            importMWReq=template;
            importMWReq.name=getString(message('Slvnv:slreq:ImportContentFromDocument'));
            importMWReq.tag='RequirementSet:ImportContentFromDocument';
            importMWReq.callback='slreq.das.RequirementSet.onImportFromDocument()';

            importRef=template;
            importRef.name=getString(message('Slvnv:slreq:CreateReferencesToDocument'));
            importRef.tag='RequirementSet:CreateReferencesToDocument';
            importRef.callback='slreq.das.RequirementSet.onCreateReferencesToDocument()';

            if this.dataModelObj.isOSLC()

                importMWReq.enabled='off';
                importRef.enabled='off';
            end

            save=template;
            save.name=getString(message('Slvnv:slreq:Save'));
            save.tag='RequirementSet:Save';
            save.callback='slreq.das.RequirementSet.onSave()';
            if~ishandle(caller)
                save.accel='Ctrl+s';
            end

            saveAs=template;
            saveAs.name=getString(message('Slvnv:slreq:SaveAs'));
            saveAs.tag='RequirementSet:SaveAs';
            saveAs.callback='slreq.das.RequirementSet.onSaveAs()';

            if strcmp(caller,'standalone')
                close=template;
                close.name=getString(message('Slvnv:slreq:CloseName',this.Name));
                close.tag='RequirementSet:Close';
                close.callback='slreq.das.RequirementSet.onClose()';
                close.enabled=bool2OnOff(~isBackedBySlx(this));
            end

            hasChildren=~isempty(this.children);
            expandAll=template;
            expandAll.name=getString(message('Slvnv:slreq:ExpandAll'));
            expandAll.tag='Requirement:ExpandAll';
            expandAll.callback='slreq.das.Requirement.onExpandAll';
            expandAll.enabled=bool2OnOff(hasChildren);

            collapseAll=template;
            collapseAll.name=getString(message('Slvnv:slreq:CollapseAll'));
            collapseAll.tag='Requirement:CollapseAll';
            collapseAll.callback='slreq.das.Requirement.onCollapseAll';
            collapseAll.enabled=bool2OnOff(hasChildren);


            viewinproject=template;
            viewinproject.name=getString(message('Slvnv:slreq:ViewInProject'));
            viewinproject.callback='slreq.das.RequirementSet.onViewInProject()';
            if~slreq.app.ProjectManager.isFileInLoadedProject(this.Filepath)
                viewinproject.visible='off';
                viewinproject.enabled='off';
            end

            redirectLinks=template;
            redirectLinks.name=getString(message('Slvnv:slreq:RedirectLinksToImportedContent'));
            redirectLinks.tag='RequirementSet:RedirectLinksToImportedContent';
            redirectLinks.callback='slreq.app.CallbackHandler.redirectLinksToImportedReqs()';

            report=template;
            report.name=getString(message('Slvnv:slreq:GenerateReport'));
            report.tag='RequirementSet:GenerateReport';
            report.callback='slreq.das.RequirementSet.onGenerateReport()';

            if ishandle(caller)

                spInspectorMenu=template;
                spInspectorMenu.name=getString(message('Slvnv:slreq:Inspect'));
                spInspectorMenu.tag='RequirementSet:Inspect';
                spInspectorMenu.callback='slreq.gui.ReqSpreadSheet.openPropertyInspector';

                remove=template;
                remove.name=getString(message('Slvnv:slreq:Remove'));
                remove.tag='RequirementSet:Remove';
                remove.callback='slreq.gui.ReqSpreadSheet.removeReqSetFromLinkSet';

                spObj=this.view.getCurrentSpreadSheetObject(caller);

                if isempty(spObj)
                    remove.enabled='off';
                else
                    remove.enabled='on';
                    if spObj.isInspectorVisible

                        spInspectorMenu.enabled='off';
                        spInspectorMenu.visible='off';
                    end
                end

                item{1}=spInspectorMenu;
                item{2}=[addReq,paste];
                item{3}=[save,saveAs,remove];
                item{4}=[importMWReq,importRef];
                item{5}=[expandAll,collapseAll];
                item{6}=viewinproject;
                item{7}=redirectLinks;
                item{8}=report;

            else

                item{1}=[addReq,paste];
                item{2}=[save,saveAs,close];
                item{3}=[importMWReq,importRef];
                item{4}=[expandAll,collapseAll];
                item{5}=viewinproject;
                item{6}=redirectLinks;
                item{7}=report;



                reqEditor=slreq.app.MainManager.getInstance.requirementsEditor;
                if~isempty(reqEditor)
                    if reqEditor.displayVerificationStatus
                        verificationLinks=slreq.data.ResultManager.getHierarchicalLinksForRequirement(this);
                        if slreq.data.ResultManager.getInstance.hasNecessaryVerificationProducts(verificationLinks)
                            runTests=template;
                            runTests.name=getString(message('Slvnv:rmisl:menus_rmi_object:RunTestMenuItemName'));
                            runTests.tag='Requirement:RunTests';
                            runTests.callback='slreq.app.CallbackHandler.onOpenTestExecutionDialog';
                            if isempty(verificationLinks)
                                runTests.enabled='off';
                            end
                            item{7}=runTests;
                        end
                    end
                end
            end

            baseItems=this.getBaseContextMenuItems(caller);
            items=[item,baseItems];

            dpMenu=template;
            dpMenu.name=getString(message('Slvnv:slreq_tracediagram:ContextMenu'));
            dpMenu.tag='RequirementSet:TraceDiagram';
            dpMenu.callback='slreq.internal.tracediagram.utils.generateTraceDiagram';
            items=[items,{dpMenu}];

            enabledTagsOnMultiSelection={save.tag};
            items=cntxtMenuBuilder.adjustMenuEnabledStateBySelection(items,enabledTagsOnMultiSelection);

        end

        function menu=getContextMenu(this,nodes)%#ok<INUSD>
            items=this.getContextMenuItems('standalone');
            menu=this.view.requirementsEditor.createContextMenu(items);
        end

        function addChild(this,req)
            reqDasObj=slreq.das.Requirement();
            reqDasObj.postConstructorProcess(req,this,this.view,this.eventListener);
            if isempty(req.parent)
                this.addChildObject(reqDasObj);
            else
                parentDasObj=req.parent.getDasObject();
                if~isempty(parentDasObj)
                    parentDasObj.addChildObject(reqDasObj);
                else

                end
            end
        end

        function out=get.PreSaveFcn(this)
            out=this.dataModelObj.preSaveFcn;
            if isempty(out)
                out=getPreFillCallbackInfo('PreSaveFcn');

            end
        end

        function out=get.PostLoadFcn(this)
            out=this.dataModelObj.postLoadFcn;

            if isempty(out)
                out=getPreFillCallbackInfo('PostLoadFcn');
            end

        end

        function set.PreSaveFcn(this,value)
            this.dataModelObj.preSaveFcn=value;
        end

        function set.PostLoadFcn(this,value)
            this.dataModelObj.postLoadFcn=value;
        end


        function dlgstruct=getDialogSchema(this,dlg)
            viewInfo=slreq.internal.gui.ViewForDDGDlg(this.view);

            if isempty(viewInfo.tag)
                dlgstruct=getDialogSchema@slreq.das.BaseObject(this,dlg);
                return;
            end

            propGroup=slreq.gui.generateDDGStructForProperties(this,{...
            'Filepath','Revision','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn','Description'},...
            'togglepanel','ReqSetProperties',getString(message('Slvnv:slreq:Properties')));
            propGroup.Expand=slreq.gui.togglePanelHandler('get',propGroup.Tag,true);
            propGroup.ExpandCallback=@slreq.gui.togglePanelHandler;

            customAttrPanel=slreq.gui.CustomAttributeRegistryPanel.getDialogSchema(this);



            enableOuterPanel=viewInfo.enableOuterPanel;
            outerPanel=struct('Type','panel','Tag','ReqSetOuterPanel','Enabled',enableOuterPanel);
            outerPanel.Items={propGroup,customAttrPanel};
            if reqmgt('rmiFeature','ReqCallbacks')
                callbackPanel=slreq.internal.gui.createCallbackTabs(this,{'PostLoadFcn','PreSaveFcn'});
                outerPanel.Items{end+1}=callbackPanel;
            end

            dlgstruct.Items={outerPanel};



            dlgstruct.DialogTitle='';
            dlgstruct.DialogTag=viewInfo.tag;
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.RowStretch=[0,1];



        end

        function yesno=isEditablePropertyInInspector(this,propName)%#ok<INUSL>
            if any(strcmp(propName,{'Description','IdPrefix','IdDelimiter'}))
                yesno=true;
            else
                yesno=false;
            end
        end

        function stereotypes=getAllStereotypes(this)
            stereotypes=this.dataModelObj.getAllStereotypes();
        end

        function profProps=getAllProfileProperties(this)

            stereotypes=this.dataModelObj.getAllStereotypes();
            profProps=slreq.internal.ProfileTypeBase.getAllProperties(stereotypes);
        end
    end

    methods(Static)
        function onAddRequirement()
            appmgr=slreq.app.MainManager.getInstance();
            currentReqSet=appmgr.getCurrentObject();
            if isa(currentReqSet,'slreq.das.RequirementSet')
                appmgr.callbackHandler.addChildRequirement(currentReqSet);
            end
        end

        function onImportFromDocument()
            appmgr=slreq.app.MainManager.getInstance();
            currentReqSet=appmgr.getCurrentObject();
            if isa(currentReqSet,'slreq.das.RequirementSet')
                slreq.import.importContentFromDoc(currentReqSet.dataModelObj);
            end
        end

        function onCreateReferencesToDocument()
            appmgr=slreq.app.MainManager.getInstance();
            currentReqSet=appmgr.getCurrentObject();
            if isa(currentReqSet,'slreq.das.RequirementSet')
                slreq.import.createReferencesToDoc(currentReqSet.dataModelObj);
            end
        end

        function onSave()
            appmgr=slreq.app.MainManager.getInstance();
            currentReqSet=appmgr.getCurrentObject();
            if isa(currentReqSet,'slreq.das.RequirementSet')
                appmgr.callbackHandler.saveReqLinkSet(currentReqSet);
            end
        end

        function onSaveAs()
            appmgr=slreq.app.MainManager.getInstance();
            currentReqSet=appmgr.getCurrentObject();
            if isa(currentReqSet,'slreq.das.RequirementSet')
                appmgr.callbackHandler.saveReqLinkSet(currentReqSet,true);
            end
        end


        function onGenerateReport()

            appmgr=slreq.app.MainManager.getInstance();
            cview=appmgr.getCurrentView();
            cobj=cview.getCurrentSelection();

            reqdata=slreq.data.ReqData.getInstance;
            allreqsets=reqdata.getLoadedReqSets;
            slreq.report.utils.openOptionDlg(allreqsets,cobj);
        end

        function onPasteItem()
            currentReqSet=slreq.app.MainManager.getCurrentObject();
            if isa(currentReqSet,'slreq.das.RequirementSet')
                slreq.app.CallbackHandler.pasteItem(currentReqSet);
            end
        end

        function onClose()


            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('MESleepEvent');

            appmgr=slreq.app.MainManager.getInstance();
            currentReqSets=slreq.app.MainManager.getCurrentObject();
            for n=1:length(currentReqSets)
                if isa(currentReqSets(n),'slreq.das.RequirementSet')
                    appmgr.callbackHandler.closeReqLinkSet(currentReqSets(n));
                end
            end


            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('MEWakeEvent');
        end


        function onViewInProject()
            appmgr=slreq.app.MainManager.getInstance();
            currentReqSet=appmgr.getCurrentObject();
            filepath=currentReqSet.Filepath;
            slreq.app.ProjectManager.highlightFileInProject(filepath);
        end


    end

    methods
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    end
end

function onoff=bool2OnOff(tf)
    if tf
        onoff='on';
    else
        onoff='off';
    end
end


function out=getPreFillCallbackInfo(callbackName)

    out=['% ',getString(message(['Slvnv:slreq:CallbackTooltip',callbackName]))];
end