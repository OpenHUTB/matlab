classdef SpreadSheetManager<handle








    properties
        appmgr;


spreadSheetMap
    end

    methods
        function this=SpreadSheetManager(appmgr)
            this.appmgr=appmgr;
            this.spreadSheetMap=containers.Map('KeyType','double','ValueType','Any');
        end

        function delete(this)
            modelHs=this.spreadSheetMap.keys;
            for n=1:length(modelHs)
                spObj=this.spreadSheetMap(modelHs{n});
                spObj.delete;
                if isKey(this.spreadSheetMap,modelHs{n})






                    this.spreadSheetMap.remove(modelHs{n});
                end
            end
        end

        function spObj=attachSpreadSheet(this,target,mDataTarget,studio)
            modelH=rmisl.getOwnerModelFromHarness(target);
            mDataModelH=rmisl.getOwnerModelFromHarness(mDataTarget);
            if~isempty(modelH)
                if~isKey(this.spreadSheetMap,modelH)
                    spObj=slreq.gui.ReqSpreadSheet(modelH,mDataModelH,studio);

                    this.spreadSheetMap(modelH)=spObj;
                else

                    spObj=this.spreadSheetMap(modelH);
                    showPI=isempty(slmle.api.getActiveEditor);
                    spObj.show(studio,showPI);
                end
            end
        end

        function detachSpreadSheet(this,target)
            modelH=rmisl.getOwnerModelFromHarness(target);
            if isKey(this.spreadSheetMap,modelH)
                spObj=this.spreadSheetMap(modelH);
                if isvalid(spObj)
                    spObj.hide();
                    if spObj.isInspectorVisible





                        if~isempty(slmle.api.getActiveEditor)
                            spObj.hidePropertyInspector();
                        end
                    end
                else
                    this.appmgr.clearLastOperatedView(spObj);
                    this.spreadSheetMap.remove(modelH);
                end
            end
        end

        function spObj=getSpreadSheetObject(this,target)
            spObj=[];
            modelH=rmisl.getOwnerModelFromHarness(target);
            if isKey(this.spreadSheetMap,modelH)
                spObj=this.spreadSheetMap(modelH);
                slreq.utils.assertValid(spObj);
            end
        end

        function spObj=getCurrentSpreadSheetObject(this,mTargetHandle,isVisibleOnly)





            spObj=[];
            if isempty(mTargetHandle)||(isnumeric(mTargetHandle)&&(mTargetHandle==-1))
                return;
            end
            modelH=rmisl.getOwnerModelFromHarness(mTargetHandle);
            [~,allModelH]=slreq.utils.DAStudioHelper.getActiveStudios(modelH,true);

            allModelH=unique(allModelH,'stable');
            if~isempty(allModelH)
                cObj=this.getSpreadSheetObject(allModelH(1));
                if~isempty(cObj)
                    if isVisibleOnly
                        if cObj.isComponentVisible
                            spObj=cObj;
                        else

                        end
                    else
                        spObj=cObj;
                    end
                    return;
                end
            end
        end

        function spObj=getAllSpreadSheetObjects(this,mTargetHandle,visibleOnly)








            if nargin<3
                visibleOnly=false;
            end
            spObj=slreq.gui.ReqSpreadSheet.empty;
            modelH=rmisl.getOwnerModelFromHarness(mTargetHandle);
            allSpObjs=this.spreadSheetMap.values();
            for index=1:length(allSpObjs)
                cSp=allSpObjs{index};
                if cSp.getCurrentModelH==modelH&&~any(spObj==cSp)
                    if visibleOnly
                        if cSp.isComponentVisible
                            spObj(end+1)=cSp;%#ok<AGROW>
                        end
                        continue;
                    end
                    spObj(end+1)=cSp;%#ok<AGROW>
                end
            end

        end

        function updateSpreadSheetForTarget(this,mTarget)
            allSpObjs=this.getAllSpreadSheetObjects(mTarget);
            for spObj=allSpObjs
                spObj.update();
            end
        end

        function deleteSpreadSheetObject(this,target)
            modelH=rmisl.getOwnerModelFromHarness(target);
            if isKey(this.spreadSheetMap,modelH)
                spObj=this.spreadSheetMap(modelH);



                this.appmgr.getViewSettingsManager.saveViewSettingsFor(spObj);
                this.spreadSheetMap.remove(modelH);
                if isvalid(spObj)
                    spObj.delete;
                end
            end
        end

        function hdls=getAllModelHandles(this)

            hdls=cell2mat(this.spreadSheetMap.keys);
        end

        function clearCurrentObj(this,clearObj,forceClear)

            if nargin<3
                forceClear=false;
            end



            spObjs=this.spreadSheetMap.values;
            for n=1:length(spObjs)
                spObj=spObjs{n};
                spObj.clearCurrentObj(clearObj,forceClear);
            end
        end

        function out=hasData(this)
            out=this.spreadSheetMap.Count~=0;
        end

        function updateOnLinkCreation(this,dataLink)
            try
                if this.spreadSheetMap.Count==0




                    return;
                end
                if strcmp(dataLink.source.domain,'linktype_rmi_simulink')
                    [~,modelName]=fileparts(dataLink.source.artifactUri);
                elseif strcmp(dataLink.dest.domain,'linktype_rmi_simulink')
                    [~,modelName]=fileparts(dataLink.dest.artifactUri);
                else
                    return;
                end
                this.updateDisplayedReqSets(modelName);

            catch ME %#ok<NASGU>

            end
        end

        function updateDisplayedReqSets(this,modelName)
            modelH=get_param(modelName,'Handle');


            allSpObjs=this.getAllSpreadSheetObjects(modelH);
            for cSpObj=allSpObjs
                cSpObj.updateDisplayedReqSet;
            end
        end

        function out=hasSpreadSheets(this,modelH,visibleOnly)
            if nargin<3
                visibleOnly=false;
            end
            out=~isempty(this.getAllSpreadSheetObjects(modelH,visibleOnly));
        end

        function refreshUI(this,dasObj)
            spObjs=this.spreadSheetMap.values;
            for n=1:length(spObjs)
                spObj=spObjs{n};
                slreq.utils.assertValid(spObj);
                if nargin>1
                    spObj.refreshUI(dasObj);
                else
                    spObj.refreshUI();
                end

            end
        end

        function update(this)
            spObjs=this.spreadSheetMap.values;
            for n=1:length(spObjs)
                spObj=spObjs{n};
                slreq.utils.assertValid(spObj);
                spObj.update(true);
            end










            dlg=DAStudio.ToolRoot.getOpenDialogs();

            for n=1:length(dlg)
                cdlg=dlg(n);
                if needToUpdatePropertyInspector(cdlg)
                    slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(cdlg);
                end
            end
        end

        function updateColumn(this,col,isReqView,type)








            if nargin<4
                type='sync';
            end
            modelHs=this.spreadSheetMap.keys;
            switch type
            case 'sync'
                for n=1:length(modelHs)
                    spObj=this.spreadSheetMap(modelHs{n});
                    if isReqView
                        spObj.reqColumns=col;
                    else
                        spObj.linkColumns=col;
                    end
                end
            case 'addreq'
                for n=1:length(modelHs)
                    spObj=this.spreadSheetMap(modelHs{n});
                    spObj.reqColumns=unique([spObj.reqColumns,col],'stable');
                end
            case 'addlink'
                for n=1:length(modelHs)
                    spObj=this.spreadSheetMap(modelHs{n});
                    spObj.linkColumns=unique([spObj.linkColumns,col,'stable']);
                end
            case 'removereq'
                for n=1:length(modelHs)
                    spObj=this.spreadSheetMap(modelHs{n});
                    spObj.reqColumns=setdiff(spObj.reqColumns,col,'stable');
                end
            case 'removelink'
                for n=1:length(modelHs)
                    spObj=this.spreadSheetMap(modelHs{n});
                    spObj.linkColumns=setdiff(spObj.linkColumns,col,'stable');
                end

            end
        end

        function tf=isOpenedInAnySpreadSheet(this,reqLinkSetObj)


            tf=false;
            modelHs=this.spreadSheetMap.keys;
            modelToBeChecked=[];






            for n=1:length(modelHs)
                if this.appmgr.perspectiveManager.getStatus(modelHs{n})

                    spObj=this.spreadSheetMap(modelHs{n});
                    cModelHs=spObj.modelHsInSpreadsheetMaps.keys;
                    modelToBeChecked=[modelToBeChecked,[cModelHs{:}]];%#ok<AGROW>
                end
            end


            modelToBeChecked=unique(modelToBeChecked);
            spdataMgr=this.appmgr.spreadSheetDataManager;
            for index=1:length(modelToBeChecked)
                spDataObj=spdataMgr.SpreadSheetDataMap(modelToBeChecked(index));
                if spDataObj.isReqOrLinkSetRegistered(reqLinkSetObj)


                    tf=true;
                    return;
                end
            end
        end

        function updateColumnOnCustomAttributeNameChange(this,origName,newName)
            modelHs=this.spreadSheetMap.keys;

            for n=1:length(modelHs)
                spObj=this.spreadSheetMap(modelHs{n});
                if spObj.canUpdateCustomAttributeFromColumn(origName)


                    matchIdx=strcmp(spObj.reqColumns,origName);
                    spObj.reqColumns{matchIdx}=newName;
                end
            end
        end

        function updateColumnOnCustomAttributeRemoval(this,origName)
            modelHs=this.spreadSheetMap.keys;

            for n=1:length(modelHs)
                spObj=this.spreadSheetMap(modelHs{n});
                if spObj.canUpdateCustomAttributeFromColumn(origName)
                    matchIdx=strcmp(spObj.reqColumns,origName);
                    spObj.reqColumns(matchIdx)=[];
                end
            end
        end

        function updateDisplayedReqSet(this)


            modelHs=this.spreadSheetMap.keys;
            for n=1:length(modelHs)
                spObj=this.spreadSheetMap(modelHs{n});
                spObj.updateDisplayedReqSet();
            end
        end

        function resetAllViews(this)
            modelHs=this.spreadSheetMap.keys;
            for n=1:length(modelHs)
                spObj=this.spreadSheetMap(modelHs{n});
                spObj.resetViewSettings();
            end
        end
    end
end

function trueOrFalse=needToUpdatePropertyInspector(ddgDlg)
























    tagsToRefresh={'Simulink:Model:Info',...
    'slim_annotation_dlg','Simulink:Dialog:Info'};

    if ishandle(ddgDlg)
        tag=ddgDlg.dialogTag;
        trueOrFalse=~strcmp(tag,'slreq_propertyinspector_#?#standalone#?#')&&...
        (any(strcmp(tag,tagsToRefresh))||...
        isa(ddgDlg.getDialogSource,'slreq.das.ReqLinkBase'));
    else
        trueOrFalse=false;
    end
end
