classdef CallbackHandler<handle





    properties
        appmgr;
        adapters;
    end


    properties(Constant,Hidden)

        ForceDiscard=1;
        SaveAndClose=2;
        Cancel=3;
        CloseNoPrompt=4;
    end

    methods(Access=private)


        function dasReqSet=getReqSetFromSelection(this,currentObj)%#ok<*INUSL>
            dasReqSet=[];
            if isa(currentObj,'slreq.das.Requirement')
                dasReqSet=currentObj.RequirementSet;
            elseif isa(currentObj,'slreq.das.RequirementSet')
                dasReqSet=currentObj;
            end
        end

        function dasLinkSet=getLinkSetFromReqSet(this,dasReqSet)
            dasLinkSet=[];

            if isa(dasReqSet,'slreq.das.RequirementSet')
                dataLinkSet=this.appmgr.reqRoot.reqData.getLinkSet(dasReqSet.Name);

                if~isempty(dataLinkSet)
                    dasLinkSet=dataLinkSet.getDasObject;
                end
            end
        end



        function out=isReqLinkSetInUse(this,currentObj)
            out=false;

            if this.appmgr.spreadsheetManager.isOpenedInAnySpreadSheet(currentObj)
                errordlg(getString(message('Slvnv:slreq:RequirementSetInUseMessage',currentObj.Name)),...
                getString(message('Slvnv:slreq:RequirementSetInUseTitle')),'modal');
                out=true;
            end

        end




        function doit=allowExportingDirtyReqLinkSet(this,dasReqSet)
            doit=true;

            dasLinkSet=this.getLinkSetFromReqSet(dasReqSet);

            if dasReqSet.Dirty||(~isempty(dasLinkSet)&&dasLinkSet.Dirty)
                if dasReqSet.Dirty
                    msg=getString(message('Slvnv:slreq:RequirementSetHasUnsavedChanges',dasReqSet.Name));
                else
                    msg=getString(message('Slvnv:slreq:RequirementSetHasUnsavedLinkChanges',dasReqSet.Name));
                end

                buttonName=questdlg(...
                {msg,getString(message('Slvnv:slreq:SaveAllExportQuestDlg'))},...
                getString(message('Slvnv:slreq:ExportingWithUnsavedChanges')),...
                getString(message('Slvnv:slreq:Yes')),getString(message('Slvnv:slreq:No')),getString(message('Slvnv:slreq:Yes')));

                doit=strcmp(buttonName,getString(message('Slvnv:slreq:Yes')));
            end
        end


        function action=allowClosingDirtyReqSet(this,dasReqSet)
            action=this.CloseNoPrompt;

            dasLinkSet=this.getLinkSetFromReqSet(dasReqSet);
            isLinkSetDirty=(~isempty(dasLinkSet)&&dasLinkSet.Dirty);
            if dasReqSet.Dirty||isLinkSetDirty
                if dasReqSet.Dirty&&isLinkSetDirty

                    questionMsg=getString(message('Slvnv:slreq:RequirementSetHasUnsavedChangesWithDirtyLinkSet',dasReqSet.Name));
                    saveMsg=getString(message('Slvnv:slreq:SaveReqLinkSetAndClose'));
                elseif dasReqSet.Dirty

                    questionMsg=getString(message('Slvnv:slreq:RequirementSetHasUnsavedChanges',dasReqSet.Name));
                    saveMsg=getString(message('Slvnv:slreq:SaveReqSetAndClose'));
                else

                    questionMsg=getString(message('Slvnv:slreq:RequirementSetHasUnsavedLinkChanges',dasReqSet.Name));
                    saveMsg=getString(message('Slvnv:slreq:SaveLinkSetAndClose'));
                end

                buttonName=questdlg(...
                {questionMsg,getString(message('Slvnv:slreq:DiscardChangesAndCloseQ'))},...
                getString(message('Slvnv:slreq:ClosingWithUnsavedChanges')),...
                getString(message('Slvnv:slreq:Yes')),getString(message('Slvnv:slreq:No')),saveMsg,getString(message('Slvnv:slreq:Yes')));

                switch buttonName
                case getString(message('Slvnv:slreq:No'))
                    action=this.Cancel;
                case getString(message('Slvnv:slreq:Yes'))
                    action=this.ForceDiscard;
                case saveMsg
                    action=this.SaveAndClose;
                otherwise
                    action=this.Cancel;
                end
            end
        end
    end

    methods




        function this=CallbackHandler(mgr)
            this.appmgr=mgr;
            this.adapters=slreq.adapters.AdapterManager.getInstance();
        end

        function reqSetDas=addNewReqSet(this)
            reqRoot=this.appmgr.getReqRoot();


            pathToFile=slreq.uri.getNewReqSetFilePath('',true);
            if isempty(pathToFile)
                reqSetDas=slreq.das.RequirementSet.empty();
                return
            end

            reqSetDas=reqRoot.addRequirementSet(pathToFile);
        end

        function filepath=pickProfile(this,cbinfo)
            filepath=[];
            [filename,pathname]=uigetfile('*.xml',...
            getString(message('Slvnv:slreq:SelectTheRequirementSetFile')));
            if~isequal(filename,0)
                filepath=fullfile(pathname,filename);
            end
        end



        function reqSetDas=openReqSet(this,cbinfo)
            if nargin==1
                cbinfo=[];
            end

            reqSetDas=slreq.das.RequirementSet.empty();
            [filename,pathname]=uigetfile('*.slreqx;*.slx',...
            getString(message('Slvnv:slreq:SelectTheRequirementSetFile')));
            if~isequal(filename,0)
                filepath=fullfile(pathname,filename);

                reqSetDas=this.loadReqSet(filepath,cbinfo);
            end
        end


        function reqSetDas=loadReqSet(this,filepath,cbinfo)

            mdl=mf.zero.Model();
            [~,~,fExt]=fileparts(filepath);
            if strcmpi(fExt,'.slreqx')

                [pc,ns]=slreq.internal.ProfileReqType.areProfilesOutdated(filepath,mdl);
            else

                pc=[];
                ns=[];
            end
            if isempty(pc)||~pc.isProfileOutdated

                reqSetDas=this.continueLoadReqSet(filepath,pc,ns);
            else
                dlg=slreq.gui.OutdatedProfileDialog(filepath,pc,ns,mdl,this,cbinfo);
                DAStudio.Dialog(dlg);
                reqSetDas=[];
            end
        end

        function resolveProfileShowReqSet(this,filepath,profChecker,profNs,mdl,cbinfo)
            reqSetDas=slreq.das.RequirementSet.empty();

            reqRoot=this.appmgr.getReqRoot();

            try
                reqSetDas=reqRoot.loadRequirementSet(filepath,true,profChecker,profNs);
            catch ex
                errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
                return;
            end

            this.appmgr.update(false);

            cView=this.appmgr.getCurrentView;
            if~isempty(reqSetDas)&&~isempty(cView)&&isvalid(cView)&&cView.isReqView

                cView.setSelectedObject(reqSetDas);
            end

            if isempty(reqSetDas)

                return;
            end


            if~isempty(cbinfo)
                if slreq.toolstrip.isEditor(cbinfo)
                    modelH=-1;
                else
                    modelH=slreq.toolstrip.getModelHandle(cbinfo);
                end
                currentView=this.appmgr.getSpreadSheetObject(modelH);
            end

            if isa(currentView,'slreq.gui.ReqSpreadSheet')
                this.appmgr.setLastOperatedView(currentView);

                currentView.createAndRegisterLinkSet(reqSetDas);
                currentView.update();
            end


            this.appmgr.notify('WakeUI');
            if~isempty(currentView)
                currentView.setSelectedObject(reqSetDas);
            end

        end

        function reqSetDas=continueLoadReqSet(this,filepath,profChecker,nSpace)
            reqSetDas=slreq.das.RequirementSet.empty();

            reqRoot=this.appmgr.getReqRoot();

            try
                reqSetDas=reqRoot.loadRequirementSet(filepath,true,profChecker,nSpace);
            catch ex
                errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
                return;
            end


            this.appmgr.update(false);

            cView=this.appmgr.getCurrentView;
            if~isempty(reqSetDas)&&~isempty(cView)&&isvalid(cView)&&cView.isReqView

                cView.setSelectedObject(reqSetDas);
            end

            [~,~,fExt]=fileparts(filepath);
            if strcmp(fExt,'.slx')

                open_system(filepath);
            end
        end

        function saveReqLinkSet(this,currentObj,isSaveAs)
            slreq.utils.assertValid(currentObj);

            if isempty(currentObj)
                return;
            end
            if nargin<3

                isSaveAs=false;
            end

            if isa(currentObj,'slreq.das.Requirement')


                reqLinkSetDas=currentObj.RequirementSet;
            elseif isa(currentObj,'slreq.das.Link')

                reqLinkSetDas=currentObj.getLinkSet;
            else
                reqLinkSetDas=currentObj;
            end

            if isa(reqLinkSetDas,'slreq.das.RequirementSet')

                if isSaveAs
                    eemgr=this.appmgr.externalEditorManager;
                    if~eemgr.detachExternalEditors('Slvnv:slreq:ExternalEditorInUseWhenSaveAs')
                        return;
                    end
                    try
                        reqLinkSetDas.saveRequirementSet('SaveAs');
                    catch ex
                        errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
                    end
                else
                    try

                        arrayfun(@(x)x.saveRequirementSet(),reqLinkSetDas);
                    catch ex
                        errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
                    end
                end
            elseif isa(reqLinkSetDas,'slreq.das.LinkSet')
                try
                    arrayfun(@(x)x.saveLinkSet(x.Filepath),reqLinkSetDas);
                catch ex
                    errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
                end
            else
                disp(getString(message('Slvnv:slreq:SelectARequirementSetYouWantToSave')));
                return;
            end




            this.appmgr.update(true);
            if isscalar(currentObj)



                this.appmgr.getCurrentView.setSelectedObject(currentObj);
            end
        end

        function exportToReqIF(this,currentObj)
            slreq.utils.assertValid(currentObj);

            dasReqSet=this.getReqSetFromSelection(currentObj);
            if isempty(dasReqSet)
                return;
            end

            if isa(currentObj,'slreq.das.Requirement')
                reqifExportNode=currentObj.getRootNode();
            else
                reqifExportNode=[];
            end

            try
                dasReqSet.exportToReqIF(reqifExportNode);
            catch ex %#ok<NASGU>

            end
        end

        function exportToPreviousReqSet(this,currentObj)
            slreq.utils.assertValid(currentObj);

            dasReqSet=this.getReqSetFromSelection(currentObj);
            if isempty(dasReqSet)
                return;
            end




            if this.isReqLinkSetInUse(dasReqSet)
                return;
            end

            if~this.allowExportingDirtyReqLinkSet(dasReqSet)
                return;
            end

            try
                statusData=dasReqSet.exportToPreviousReqSet();


                if(statusData.success)
                    reqRoot=this.appmgr.getReqRoot();
                    reqRoot.showSuggestion(statusData.id,statusData.message);
                end

            catch ex
                errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
            end



            this.appmgr.update(true);



        end

        function saveAllReqLinkSet(this,currentObj)

            this.saveAllReqSets(currentObj,false);

            this.saveAllLinkSets(currentObj,false);




            this.appmgr.update(true);
            if~isempty(currentObj)
                this.appmgr.getCurrentView.setSelectedObject(currentObj);
            end
        end

        function saveAllReqSets(this,currentObj,doUpdate)

            dasReqSets=this.appmgr.reqRoot.children;
            for n=1:length(dasReqSets)
                dasReqSet=dasReqSets(n);
                if dasReqSet.Dirty
                    dasReqSet.saveRequirementSet();
                end
            end

            if doUpdate


                this.appmgr.update(true);
                if~isempty(currentObj)
                    this.appmgr.getCurrentView.setSelectedObject(currentObj);
                end
            end
        end

        function saveAllLinkSets(this,currentObj,doUpdate)
            dasLinkSets=this.appmgr.linkRoot.children;
            for n=1:length(dasLinkSets)
                dasLinkSet=dasLinkSets(n);
                if dasLinkSet.Dirty
                    dasLinkSet.saveLinkSet();
                end
            end

            if doUpdate


                this.appmgr.update(true);
                if~isempty(currentObj)
                    this.appmgr.getCurrentView.setSelectedObject(currentObj);
                end
            end
        end

        function closeReqLinkSet(this,dasReqSet)



            if this.isReqLinkSetInUse(dasReqSet)
                return;
            end
            action=this.allowClosingDirtyReqSet(dasReqSet);

            if action==this.Cancel
                return;
            end


            this.appmgr.clearSelectedObjectsUponDeletion(dasReqSet);

            if action==this.SaveAndClose||action==this.ForceDiscard
                dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(dasReqSet.Name,'linktype_rmi_slreq');
                if~isempty(dataLinkSet)
                    if dataLinkSet.dirty&&action==this.SaveAndClose
                        dataLinkSet.save();
                    end
                    lsm=slreq.linkmgr.LinkSetManager.getInstance();
                    lsm.clearAllReferencesForLinkSet(dataLinkSet);
                end
                if dasReqSet.Dirty&&action==this.SaveAndClose
                    dasReqSet.saveRequirementSet();
                end
            end

            dasReqSet.discard();
        end

        function newReqDas=addRequirementAfter(this,currentObj)
            slreq.utils.assertValid(currentObj);

            newReqDas=[];
            if isempty(currentObj)
                return;
            end
            if isa(currentObj,'slreq.das.RequirementSet')...
                ||isa(currentObj,'slreq.das.Requirement')
                newReqDas=currentObj.addRequirementAfter();
                reqSetData=currentObj.dataModelObj.getReqSet;
                if~isempty(reqSetData)
                    reqSetData.updateHIdx();
                end


                view=this.appmgr.getCurrentView();
                if~isempty(view)
                    view.setSelectedObject(newReqDas);
                end
            end
        end

        function newReqDas=addChildRequirement(this,currentObj)
            slreq.utils.assertValid(currentObj);

            newReqDas=[];
            if isempty(currentObj)
                return;
            end
            if isa(currentObj,'slreq.das.RequirementSet')
                newReqDas=currentObj.addRequirement();
            elseif isa(currentObj,'slreq.das.Requirement')
                newReqDas=currentObj.addChildRequirement();
            end
            view=this.appmgr.getCurrentView();
            if~isempty(view)&&~isempty(newReqDas)


                view.setSelectedObject(newReqDas);
            end
        end

        function delReqLink(this,currentObj)
            slreq.utils.assertValid(currentObj);

            if isempty(currentObj)||isempty(currentObj(1).parent)

                return;
            end
            isMultiSelection=numel(currentObj)>1;
            if isa(currentObj,'slreq.das.Requirement')&&any([currentObj.isExternal])
                if~isMultiSelection&&currentObj.dataModelObj.isImportRootItem()

                    title=getString(message('Slvnv:slreq:DeleteConfirmationTitle'));
                    questionStr=getString(message('Slvnv:slreq:DeleteConfirmationQuestion',currentObj.Index));
                    YesStr=getString(message('Slvnv:slreq:Yes'));
                    NoStr=getString(message('Slvnv:slreq:No'));
                    buttonName=questdlg(questionStr,title,YesStr,NoStr,NoStr);
                    if~strcmp(buttonName,YesStr)


                        return;
                    end
                else



                    return;
                end
            end


            nextSelection=currentObj.getNextSelectionObjAfterRemoval();
            delLink=false;
            if isa(currentObj,'slreq.das.Link')
                delLink=true;
                this.appmgr.clearSelectedObjectsUponDeletion(currentObj);




                for n=1:length(currentObj)
                    [srcAdapter,srcArtifactUri,srcArtifactId]=currentObj(n).dataModelObj.source.getAdapter();
                    if n==1
                        srcStruct=struct('artifactUri',srcArtifactUri,'artifactId',srcArtifactId);
                    else
                        srcStruct(n)=struct('artifactUri',srcArtifactUri,'artifactId',srcArtifactId);
                    end
                end
            end
            if isMultiSelection

                this.appmgr.notify('SleepUI');
                arrayfun(@(x)x.remove(),currentObj);
                c=onCleanup(@()this.appmgr.notify('WakeUI'));
            else
                currentObj.remove();
            end
            if delLink





                this.appmgr.update(false);
                for n=1:length(srcStruct)
                    srcAdapter.refreshLinkOwner(srcStruct(n).artifactUri,srcStruct(n).artifactId,rmi.createEmptyReqs(1),[]);
                end
            end
            this.appmgr.getCurrentView.setSelectedObject(nextSelection);
        end

        function promote(this,currentObj)
            slreq.utils.assertValid(currentObj);

            if isempty(currentObj)
                return;
            end
            if isa(currentObj,'slreq.das.Requirement')
                currentObj.promote();




                this.appmgr.update(true);
                view=this.appmgr.getCurrentView();
                if~isempty(view)
                    view.setSelectedObject(currentObj);
                end
            else
                warning(getString('Slvnv:slreq:WarningForPromote'));
            end
        end

        function demote(this,currentObj)
            slreq.utils.assertValid(currentObj);

            if isempty(currentObj)
                return;
            end
            if isa(currentObj,'slreq.das.Requirement')

                currentObj.demote();




                this.appmgr.update(true);
                view=this.appmgr.getCurrentView();
                if~isempty(view)
                    view.setSelectedObject(currentObj);
                end
            else
                warning(getString(message('Slvnv:slreq:WarningForDemote')));
            end
        end

        function allow=onDrag(this,source,destination,location,action)
            srcReq=source{1};
            allow=srcReq.isDropAllowedFor(destination,location,action);
        end

        function onDrop(this,source,destination,location,action)
            if strcmp(action,'move')
                dst=destination;
                dataDst=dst.dataModelObj;

                lenSource=length(source);
                if lenSource>1


                    stopAction=slreq.app.MainManager.getInstance.startUserAction;%#ok<NASGU> 
                end


                pendingUpdateStruct.movedDataReqs={};
                pendingUpdateStruct.changedInfos={};
                pendingUpdateStruct.doNotify=false;

                for n=1:lenSource
                    if iscell(source)
                        srcDasReq=source{n};
                    else
                        srcDasReq=source(n);
                    end

                    if~srcDasReq.isDropAllowedFor(destination,location,action)

                        return;
                    end

                    dataSrc=srcDasReq.dataModelObj;


                    pendingUpdateStruct.doNotify=(n==lenSource);



                    if lenSource==1
                        dataSrc.moveTo(location,dataDst);
                    else
                        [~,pendingUpdateStruct]=dataSrc.moveTo(location,dataDst,pendingUpdateStruct);
                    end





                    if isa(destination,'slreq.das.Requirement')
                        srcDasReq.RequirementSet=destination.RequirementSet;
                    elseif isa(destination,'slreq.das.RequirementSet')
                        srcDasReq.RequirementSet=destination;
                    end

                    if strcmp(location,'after')



                        dataDst=dataSrc;
                    end
                end
            end
        end

        function addJustification(this,selectedObj)
            slreq.utils.assertValid(selectedObj);

            if isempty(selectedObj)
                return;
            end
            if isa(selectedObj,'slreq.das.RequirementSet')
                newJust=selectedObj.dataModelObj.addJustification;
            elseif(isa(selectedObj.parent,'slreq.das.RequirementSet')&&selectedObj.dataModelObj.isJustification)
                newJust=selectedObj.dataModelObj.addChildJustification;
            else
                newJust=selectedObj.dataModelObj.addJustificationAfter;
            end

            newJustDas=newJust.getDasObject();
            if~isempty(newJustDas)
                this.appmgr.getCurrentView.setSelectedObject(newJustDas);
            end
        end

        function addJustificationAndLink(this,reqObj,linkType)
            slreq.utils.assertValid(reqObj);

            if isempty(reqObj)
                return;
            end
            justData=reqObj.dataModelObj.addChildJustification;


            reqObj.dataModelObj.addLink(justData,linkType);



            this.appmgr.update(true);
        end
    end

    methods(Static,Hidden)

        function callbackForChangeOfCallbackText(obj,tag,value)



            obj.(tag)=value;
        end

        function selectObjectByUuid(uuid,caller)


            if strcmp(caller,'standalone')
                slreq.internal.gui.Editor.selectObjectByUuid(uuid);
            else




                isSelected=false;
                try
                    appmgr=slreq.app.MainManager.getInstance();
                    targetObj=slreq.utils.findDASbyUUID(uuid);
                    setObj=slreq.das.ReqLinkBase.empty();
                    if isa(targetObj,'slreq.das.Requirement')
                        setObj=targetObj.RequirementSet;
                    elseif isa(targetObj,'slreq.das.RequirementSet')
                        setObj=targetObj;
                    elseif isa(targetObj,'slreq.das.Link')
                        setObj=targetObj.getLinkSet;
                    elseif isa(targetObj,'slreq.das.LinkSet')
                        setObj=targetObj;
                    end

                    modelH=get_param(caller,'Handle');
                    spObj=appmgr.getCurrentSpreadSheetObject(modelH);
                    if isempty(spObj)




                        slreq.internal.gui.Editor.selectObjectByUuid(uuid);
                    else
                        if spObj.isReqOrLinkSetRegistered(setObj)



                            spObj.setHighlightedObject(targetObj,true);
                            isSelected=true;
                        end
                    end
                catch mx %#ok<NASGU>
                end
                if~isSelected

                    slreq.internal.gui.Editor.selectObjectByUuid(uuid);
                end

            end
        end

        function cutItem(currentObjs)
            if~isempty(currentObjs)
                reqData=slreq.data.ReqData.getInstance();
                dataReqSet=currentObjs(1).dataModelObj.getReqSet;


                nextSelection=currentObjs.getNextSelectionObjAfterRemoval;
                dataObjs=arrayfun(@(x)x.dataModelObj,currentObjs);
                reqData.cutReqToClipboard(dataObjs);


                dataReqSet.updateHIdx();


                if~isempty(nextSelection)
                    nextSelection.view.getCurrentView.setSelectedObject(nextSelection);
                end



            end
        end

        function copyItem(currentObjs)
            if~isempty(currentObjs)
                reqData=slreq.data.ReqData.getInstance();
                dataObjs=arrayfun(@(x)x.dataModelObj,currentObjs);
                reqData.copyReqToClipboard(dataObjs);
            end
        end

        function pasteItem(currentObj)
            if numel(currentObj)>1||isempty(currentObj)


                return;
            end
            reqData=slreq.data.ReqData.getInstance();
            try
                reqData.pasteFromClipboard(currentObj.dataModelObj);
            catch ex
                errordlg(ex.message,getString(message('Slvnv:slreq:PasteErrorTitle')),'modal');
            end
        end

        function[isMWReq,isExternal,isJustification]=getDasRequirementType(currentObj)
            slreq.utils.assertValid(currentObj);

            [isMWReq,isExternal,isJustification]=initflag();
            if isempty(currentObj)
                return;
            end
            hasNonReqItem=false;
            for n=1:length(currentObj)
                cObj=currentObj(n);
                if isa(cObj,'slreq.das.Requirement')
                    if cObj.isExternal
                        isExternal=true;
                    elseif cObj.isJustification
                        isJustification=true;
                    else
                        isMWReq=true;
                    end
                else
                    hasNonReqItem=true;
                end
            end
            if hasNonReqItem||...
                (isExternal+isJustification+isMWReq>1)
                [isMWReq,isExternal,isJustification]=initflag();
            end
            function[int,ext,just]=initflag()

                int=false;
                ext=false;
                just=false;
            end
        end

        function tf=isPasteAllowed(currentObj)
            tf=false;
            if numel(currentObj)>1

                return;
            end
            [isInternalReq,~,isJustification]=slreq.app.CallbackHandler.getDasRequirementType(currentObj);

            [hasCripboad,isClipboadObjJustification]=slreq.data.ReqData.getInstance().hasCripboardItem();
            if hasCripboad
                if isJustification&&isClipboadObjJustification
                    tf=true;
                elseif isInternalReq&&~isClipboadObjJustification
                    tf=true;
                elseif isa(currentObj,'slreq.das.RequirementSet')&&~isClipboadObjJustification
                    tf=true;
                end
            end
        end

        function toggleCommentDisplay(caller)

            editorStr='#?#standalone#?#';
            if nargin<1
                caller=editorStr;
            end


            cView=slreq.utils.getCallerView(caller);

            if~slreq.utils.isValidView(cView)
                return;
            end

            if strcmp(caller,editorStr)

                toBeOn=strcmp(cView.Menus.CommentDisplay.on,'on');
            else
                toBeOn=~cView.displayComment;
            end

            if toBeOn
                cView.displayComment=true;
            else
                cView.displayComment=false;
            end

            if isa(cView,'slreq.gui.ReqSpreadSheet')
                cView.update(['slreq_propertyinspector_',caller]);
            else
                cView.update;
            end
        end


        function toggleImplementationStatus(caller)




            editorStr='#?#standalone#?#';
            if nargin<1
                caller=editorStr;
            end
            cView=slreq.utils.getCallerView(caller);

            if~slreq.utils.isValidView(cView)
                return;
            end

            if strcmp(caller,editorStr)

                toBeOn=strcmp(cView.Menus.ImplementationStatus.on,'on');
            else


                toBeOn=~cView.displayImplementationStatus;
            end

            if toBeOn
                if cView.displayImplementationStatus



                    return;
                end

                cView.toggleOnImplementationStatus();
            else
                cView.toggleOffImplementationStatus();
            end
        end


        function refreshImplementationStatus()
            appmgr=slreq.app.MainManager.getInstance();
            appmgr.reqRoot.refreshImplementationStatus();

            appmgr.update(true);
        end


        function toggleVerificationStatus(caller)

            editorStr='#?#standalone#?#';
            if nargin<1
                caller=editorStr;
            end

            appmgr=slreq.app.MainManager.getInstance();
            cView=slreq.utils.getCallerView(caller);
            if~slreq.utils.isValidView(cView)
                return;
            end

            if strcmp(caller,editorStr)

                toBeOn=strcmp(cView.Menus.VerificationStatus.on,'on');
            else


                toBeOn=~cView.displayVerificationStatus;
            end

            if toBeOn
                if cView.displayVerificationStatus



                    return;
                end
                cView.toggleOnVerificationStatus();
            else
                cView.toggleOffVerificationStatus();
            end
            if ismember(caller,{editorStr,'#?#standalonecontext#?#'})

                appmgr.update(true);
            end
        end


        function refreshVerificationStatus()

            resultsManager=slreq.data.ResultManager.getInstance();
            resultsManager.resetCache();
            appmgr=slreq.app.MainManager.getInstance();
            appmgr.reqRoot.refreshVerificationStatus();

            appmgr.update(true);
        end


        function toggleChangeInformation(caller)
            editorStr='#?#standalone#?#';
            if nargin<1
                caller=editorStr;
            end

            cView=slreq.utils.getCallerView(caller);

            if~slreq.utils.isValidView(cView)
                return;
            end

            if slreq.utils.isValidView(cView)
                appmgr=slreq.app.MainManager.getInstance();
                appmgr.setLastOperatedView(cView)
            end
            if strcmp(caller,editorStr)

                toBeOn=strcmp(cView.Menus.ChangeInformation.on,'on');
            else




                toBeOn=~cView.displayChangeInformation;
            end

            if toBeOn
                if cView.displayChangeInformation



                    return;
                end
                cView.toggleOnChangeInformation();
            else
                cView.toggleOffChangeInformation();
            end
        end


        function refreshChangeInformation()
            appmgr=slreq.app.MainManager.getInstance();
            ctObj=appmgr.changeTracker();
            ctObj.refresh();
            view=appmgr.getCurrentView;
            if slreq.utils.isValidView(view)
                if isa(view,'slreq.gui.RequirementsEditor')
                    if view.isReqView
                        view.ShowSuggestion=true;
                        view.SuggestionId='Slvnv:slreq:ChangeInfoSuggestion';
                        view.SuggestionReason=getString(message(view.SuggestionId));
                    end
                end
            end



            ctObj.updateViews();
        end


        function onOpenTestExecutionDialog()
            currentReq=slreq.app.MainManager.getCurrentObject();
            if isa(currentReq,'slreq.das.Requirement')||isa(currentReq,'slreq.das.RequirementSet')
                ted=slreq.gui.TestExecutionDialog(currentReq.dataModelObj);
                ted.show();
            end

        end


        function onRefreshAllHyperlink(viewName)
            appmgr=slreq.app.MainManager.getInstance();

            view=appmgr.getCurrentView();
            slreq.app.CallbackHandler.onRefreshAll(view);
        end


        function onRefreshAll(cView)
            appmgr=slreq.app.MainManager.getInstance();
            needUpdate=appmgr.isAnalysisDeferred==true;

            appmgr.isAnalysisDeferred=false;
            appmgr.hideDeferredAnalysisNotifications();

            try
                co=appmgr.getCurrentObject;
                if~isempty(co)&&(isa(co,'slreq.das.Requirement')||isa(co,'slreq.das.RequirementSet'))
                    co.IsSleeping=false;
                end
            catch ex %#ok<NASGU>

            end

            if~isempty(cView)&&isvalid(cView)
                vm=appmgr.viewManager;
                if~vm.isVanillaActive

                    view=vm.getCurrentView;
                    view.update();
                end

                detectionMgr=slreq.dataexchange.UpdateDetectionManager.getInstance();
                needUpdate=needUpdate||detectionMgr.checkUpdatesForAllArtifacts();


                updated=appmgr.updateRollupStatusAndChangeInformationIfNeeded({cView});
                needUpdate=needUpdate||updated;
                if needUpdate
                    if isa(cView,'slreq.internal.gui.Editor')

                        appmgr.refreshUI();
                    end
                    cView.update;
                end

                cView.updateToolbar();
            end
        end


        function onClosePropertyDialog(dlg)






            try
                dlgsrc=dlg.getDialogSource;
                uuid=dlgsrc.dataUuid;
                reqData=slreq.data.ReqData.getInstance();
                dataObj=reqData.findObject(uuid);
                if~isempty(dataObj)&&isvalid(dataObj)
                    dlg.apply();
                end
            catch ex %#ok<NASGU>

            end
        end


        function redirectLinksToImportedReqs()





            mgr=slreq.app.MainManager.getInstance;
            currentViewer=mgr.getCurrentView;
            if~isempty(currentViewer)
                dasReqSet=currentViewer.getCurrentSelection();
                if isa(dasReqSet,'slreq.das.RequirementSet')


                    dataReqSet=dasReqSet.dataModelObj;
                    linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
                    convertCount=0;
                    unresolvedCount=0;
                    for i=1:numel(linkSets)
                        dataLinkSet=linkSets(i);
                        [converted,unresolved]=dataLinkSet.redirectLinksToImportedContent(dataReqSet,false);
                        convertCount=convertCount+converted;
                        unresolvedCount=unresolvedCount+unresolved;
                    end
                    slreq.utils.showLinkConversionSummary(convertCount,unresolvedCount);
                end
            end
        end

    end
end



