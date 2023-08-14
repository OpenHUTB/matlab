classdef DDSDetailsDDG<handle




    properties(Access=private)
        mDDGCmpt;
        mListCmpt;
        mObjSelected;
        mDataObj;
        mMdl;
        mUseDetailActions;
        mClientCallbacks;
    end


    methods(Static,Access=public)
        function result=handleSelectionChange(compSrc,selection,thisObj)
            if isequal(1,numel(selection))
                result=thisObj.setSelected(selection{1});
            else
                result=thisObj.setSelected([]);
            end
        end
    end


    methods(Access=public)
        function this=DDSDetailsDDG(cmptDDG,cmptList,useDetailActions)
            this.mDDGCmpt=cmptDDG;
            this.mListCmpt=cmptList;
            this.mObjSelected=[];
            this.mDataObj=[];
            this.mUseDetailActions=useDetailActions;
            this.mClientCallbacks=[];
        end

        function tabChanged(thisObj,tabName)
            thisObj.setSelected([]);
        end

        function result=setSelected(thisObj,selection)
            result=true;
            if~isempty(thisObj.mDataObj)&&thisObj.mDataObj.hasSimObject()
                dlg=thisObj.mDDGCmpt.getDialog();
                if~isempty(dlg)&&dlg.hasUnappliedChanges
                    question=message('modelexplorer:DAS:DA_APPLY_CHANGES_DESC_MSG').getString;
                    title=message('dds:ui:DDSUIDlgTitle').getString;
                    btnApply=message('modelexplorer:DAS:DA_APPLY_MSG').getString;
                    btnIgnore=message('modelexplorer:DAS:ME_IGNORE_GUI').getString;
                    answer=questdlg(question,title,btnApply,btnIgnore,btnApply);
                    if isequal(answer,btnApply)
                        dlg.apply;
                    end
                end
            end

            if isequal(1,numel(selection))
                thisObj.mObjSelected=selection{1};
            else
                thisObj.mObjSelected=[];
            end
            if~isempty(thisObj.mObjSelected)
                thisObj.mDataObj=thisObj.mObjSelected.getForwardedObject;
                thisObj.mDataObj.setShowActions(thisObj.mUseDetailActions);
            else
                thisObj.mDDGCmpt.minimize;
            end
            thisObj.mDDGCmpt.updateSource(thisObj);
            if~isempty(thisObj.mObjSelected)
                thisObj.mDDGCmpt.restore;
            end
        end

        function refresh(thisObj,changeReport)
            if~isempty(changeReport.Modified)
                fwdObj=thisObj.mDataObj.getElement();
                for i=1:numel(changeReport.Modified)
                    if isequal(fwdObj,changeReport.Modified(i).Element)
                        thisObj.refreshDlg();
                        break;
                    end
                end
            end
            if~isempty(changeReport.Destroyed)
                if~isvalid(thisObj.mDataObj.getElement)
                    thisObj.setSelected([]);
                end
            end
        end

        function refreshDlg(thisObj)
            if~isempty(thisObj.mObjSelected)
                dlg=thisObj.mDDGCmpt.getDialog();
                if~isempty(dlg)
                    dlg.refresh;
                end
            end
        end

        function userData=getUserData(thisObj)
            userData=thisObj.mDataObj.getUserData();
        end
        function setUserData(thisObj,userData)
            thisObj.mDataObj.setUserData(userData);
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)
            dlgStruct='';
            if~isempty(thisObj.mObjSelected)
                thisObj.mClientCallbacks=[];
                dlgStruct=thisObj.mDataObj.getDialogSchema(arg1);

                if thisObj.mDataObj.hasSimObject()
                    [dlgStruct,thisObj.mClientCallbacks]=...
                    thisObj.captureCallbackField('PostApplyCallback',dlgStruct,thisObj.mClientCallbacks);
                    [dlgStruct,thisObj.mClientCallbacks]=...
                    thisObj.captureCallbackField('PostApplyArgs',dlgStruct,thisObj.mClientCallbacks);





                    dlgStruct.PostApplyMethod='postApply';
                    dlgStruct.PostApplyArgs={'%dialog','%source'};
                    dlgStruct.PostApplyArgsDT={'handle','handle'};




                end
            end
        end








        function[successful,errmsg]=postApply(thisObj,dialog,source)

            [successful,errmsg]=thisObj.callClientCallback(thisObj.mClientCallbacks,...
            'PostApplyCallback','PostApplyArgs',dialog,source);
            try
                thisObj.mDataObj.putSimObject();
            catch ex
                successful=false;
                errmsg=ex.message;


                if isa(thisObj.mDataObj.getForwardedObject(),'Simulink.Bus')
                    DialogState=dialog.getUserData('MoveElementUpBtn');
                    DialogState.tempBusObject=thisObj.mDataObj.getForwardedObject();
                    dialog.setUserData('MoveElementUpBtn',DialogState)
                    dialog.setUserData('DeleteElementBtn',[]);
                end
                dialog.refresh();
            end
        end
        function changeEntryValue(thisObj,value,tag,fldName)%#ok<INUSD> 
            if isprop(thisObj.mDataObj,fldName)
                thisObj.mDataObj.(fldName)=value;
            end
        end

        function src=getForwardedObject(thisObj)
            src='';
            if~isempty(thisObj.mDataObj)
                src=thisObj.mDataObj.getForwardedObject();
            end
        end

        function setEntryValue(thisObj,newValue)
            thisObj.mDataObj.setEntryValue(newValue);
        end

        function used=useBusEditor(thisObj)
            used=false;
        end

        function used=useCodeGen(thisObj)
            used=false;
        end

        function name=getDisplayLabel(thisObj)
            name='';
        end

        function icon=getDisplayIcon(thisObj)
            icon='';
        end

        function isValid=isValidProperty(thisObj,propName)
            isValid=true;
        end

        function isReadonly=isReadonlyProperty(thisObj,propName)
            isReadonly=true;
        end

        function dataType=getPropDataType(thisObj,propName)
            dataType='string';
        end

        function values=getPropAllowedValues(thisObj,propName)
            values='';
        end

        function propVal=getPropValue(thisObj,propName)
            propVal='';
        end

        function setPropValue(thisObj,propName,propVal)
        end
    end


    methods(Access=private)

        function[dlgstruct,clientCallbacks]=captureCallbackField(thisObj,callbackFieldName,dlgstruct,clientCallbacks)
            if isfield(dlgstruct,callbackFieldName)
                clientCallbacks.(callbackFieldName)=dlgstruct.(callbackFieldName);
                dlgstruct=rmfield(dlgstruct,callbackFieldName);
            end
        end

        function[successful,errmsg]=callClientCallback(thisObj,clientCallbacks,callbackFieldName,callbackArgsFieldName,...
            dialog,source)
            successful=true;
            errmsg='';
            if isfield(clientCallbacks,callbackFieldName)
                if isfield(clientCallbacks,callbackArgsFieldName)
                    clientArgs=clientCallbacks.(callbackArgsFieldName);
                    fevalArgs=cell(1,length(clientArgs));

                    for argnum=1:length(clientArgs)
                        if ischar(clientArgs{argnum})
                            if strcmp(clientArgs{argnum},'%dialog')
                                fevalArgs{argnum}=dialog;
                            elseif strcmp(clientArgs{argnum},'%source')
                                fevalArgs{argnum}=source;
                            else
                                fevalArgs{argnum}=clientArgs{argnum};
                            end
                        else
                            fevalArgs{argnum}=clientArgs{argnum};
                        end
                    end
                else
                    fevalArgs={};
                end
                if isequal(clientCallbacks,'CloseCallback')
                    feval(clientCallbacks.(callbackFieldName),fevalArgs{:});
                else
                    [successful,errmsg]=feval(clientCallbacks.(callbackFieldName),fevalArgs{:});
                end
            end
        end

    end
end
