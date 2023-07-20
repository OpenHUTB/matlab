classdef DetailsPane<handle





    properties(Access=private)
        mDDGCmpt;
        mObjSelected;
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
        function this=DetailsPane(cmptDDG)
            this.mDDGCmpt=cmptDDG;
            this.mObjSelected=[];
        end

        function tabChanged(thisObj,tabName)
            thisObj.setSelected([]);
        end

        function refresh(thisObj,refreshItem)
            if isequal(refreshItem,thisObj.mObjSelected)&&...
                isvalid(thisObj.mDDGCmpt)
                dlg=thisObj.mDDGCmpt.getDialog();
                dlg.refresh();
            end
        end

        function setSelected(thisObj,selection)
            if~isempty(selection)
                sameSource=isequal(thisObj.mObjSelected,selection{1});
            else
                sameSource=false;
            end
            if isequal(1,numel(selection))
                thisObj.mObjSelected=selection{1};
            else
                thisObj.mObjSelected=[];
            end
            if isvalid(thisObj.mDDGCmpt)
                if sameSource
                    dlg=thisObj.mDDGCmpt.getDialog();
                    dlg.refresh();
                else
                    thisObj.mDDGCmpt.updateSource(thisObj);
                end
            end
        end

        function dlgStruct=getDialogSchema(thisObj,arg1)

            panel.Type='panel';
            panel.LayoutGrid=[5,3];
            panel.RowStretch=[0,1,0,0,2];
            panel.ColStretch=[0,0,1];
            panel.Items={};

            dlgStruct.Items={panel};
            dlgStruct.EmbeddedButtonSet={''};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.DialogMode='Slim';
            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.DialogTitle='';
            dlgStruct.DialogTag='detailspane';

            if~isempty(thisObj.mObjSelected)
                thisObj.mClientCallbacks=[];
                try
                    dlgSelected=thisObj.mObjSelected.getDialogSchema(arg1);
                    if~isempty(dlgSelected)
                        dlgStruct=dlgSelected;
                    end
                catch E
                end

                if isfield(dlgStruct,'EmbeddedButtonSet')&&~isempty(dlgStruct.EmbeddedButtonSet)
                    [dlgStruct,thisObj.mClientCallbacks]=...
                    thisObj.captureCallbackField('PostApplyCallback',dlgStruct,thisObj.mClientCallbacks);
                    [dlgStruct,thisObj.mClientCallbacks]=...
                    thisObj.captureCallbackField('PostApplyArgs',dlgStruct,thisObj.mClientCallbacks);

                    dlgStruct.PostApplyMethod='postApply';
                    dlgStruct.PostApplyArgs={'%dialog','%source'};
                    dlgStruct.PostApplyArgsDT={'handle','handle'};
                else
                    dlgStruct.EmbeddedButtonSet={''};
                end

                if~isfield(dlgStruct,'StandaloneButtonSet')
                    dlgStruct.StandaloneButtonSet={''};
                end
                if~isfield(dlgStruct,'DialogMode')
                    dlgStruct.DialogMode='Slim';
                end
                if~isfield(dlgStruct,'DialogTitle')
                    dlgStruct.DialogTitle='';
                end
                if~isfield(dlgStruct,'DialogTag')
                    classname=class(thisObj.mObjSelected);
                    parts=split(classname,'.');
                    try
                        dlgStruct.DialogTag=parts{end};
                    catch
                        dlgStruct.DialogTag='';
                    end
                end
            end

        end

        function[successful,errmsg]=postApply(thisObj,dialog,source)

            [successful,errmsg]=thisObj.callClientCallback(thisObj.mClientCallbacks,...
            'PostApplyCallback','PostApplyArgs',dialog,source);
            thisObj.mObjSelected.postApply();
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
