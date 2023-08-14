



classdef ModelDictionaryViewSource<simulinkcoder.internal.app.ViewSourceBase
    properties(Hidden=true)
hModelCloseListener
stfChangeListener
        ddClientListener=[]
        ddConn=[]
        PostNameChangeId=''
view
    end
    methods
        function obj=ModelDictionaryViewSource(modelHandle)
            obj.ModelHandle=modelHandle;
            modelObject=get_param(modelHandle,'object');
            if~modelObject.hasCallback('PreClose','CoderDataUI_ModelDD_PreClose')
                Simulink.addBlockDiagramCallback(modelHandle,'PreClose','CoderDataUI_ModelDD_PreClose',...
                @obj.onSourceBeingDestroyed);
            end
            obj.stfChangeListener=configset.ParamListener(modelHandle,'SystemTargetFile',@obj.onSTFChanged);
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            cdict=hlp.openDD(obj.ModelHandle);
            coderdictionary.data.api.startChangeTracking(cdict.owner);
            obj.registerNameChangeCallback;
        end
        function onSTFChanged(obj,h,~,~)
            if obj.isvalid
                if strcmp(get_param(h,'IsERTTarget'),'off')
                    obj.onSourceBeingDestroyed;
                end
            end
        end
        function createListener(obj,clientID)

        end
        function out=getClientAssociationHandle(obj)
            out=obj.ModelHandle;
            obj.isAttachedToModel=true;
        end
        function onBrowserClose(obj,size)

            if~isempty(obj.ModelHandle)
                modelObject=get_param(obj.ModelHandle,'Object');
                if modelObject.hasCallback('PostNameChange',obj.PostNameChangeId)
                    Simulink.removeBlockDiagramCallback(obj.ModelHandle,'PostNameChange',obj.PostNameChangeId);
                end
                if modelObject.hasCallback('PreClose','CoderDataUI_ModelDD_PreClose')
                    Simulink.removeBlockDiagramCallback(obj.ModelHandle,'PreClose','CoderDataUI_ModelDD_PreClose');
                end
            end
            simulinkcoder.internal.app.View.getSetGeometry(size);
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.ModelHandle);
        end
        function onSourceBeingDestroyed(obj,~,~,~)
            try
                onSourceBeingDestroyed@simulinkcoder.internal.app.ViewSourceBase(obj);
                simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.ModelHandle);
            catch
            end
        end
        function registerNameChangeCallback(obj)
            modelHandle=obj.ModelHandle;
            bdObj=get_param(modelHandle,'Object');
            id='EmbeddedCoderDictionaryNameChangeEventID';
            if isempty(obj.PostNameChangeId)
                obj.PostNameChangeId=id;
            end
            if~bdObj.hasCallback('PostNameChange',id)
                Simulink.addBlockDiagramCallback(obj.ModelHandle,'PostNameChange',...
                id,@()obj.modelNameChangeCallback());
            end
        end
        function modelNameChangeCallback(obj)
            if~obj.isvalid
                return;
            end
            oldId=obj.PostNameChangeId;
            modelObject=get_param(obj.ModelHandle,'Object');
            if modelObject.hasCallback('PostNameChange',oldId)
                Simulink.removeBlockDiagramCallback(obj.ModelHandle,'PostNameChange',oldId);
            end
            newId=[get_param(obj.ModelHandle,'Name'),'_EmbeddedCoderDictionary'];
            obj.PostNameChangeId=newId;
            if~modelObject.hasCallback('PostNameChange',newId)
                Simulink.addBlockDiagramCallback(obj.ModelHandle,'PostNameChange',newId,...
                @()obj.modelNameChangeCallback());
            end

            if isa(obj.view,'simulinkcoder.internal.app.ViewHMIBrowserDialog')
                obj.view.Dlg.setTitle(obj.view.getDialogTitle);
            end

            obj.refreshTableFromClient('groupTable_tableStore');
            obj.refreshTableFromClient('memorySectionTable_tableStore');
            obj.refreshTableFromClient('functionClassTable_tableStore');
        end
        function refreshTableFromClient(~,objectID)
            msg=struct('objectID',objectID,...
            'messageID','dataFromServer',...
            'resetSelection',false,...
            'info',struct('operation','appendOnLoad'));
            message.publish('/prototypeTable/store',msg);
        end
        function out=CoderDataSourceName(obj)
            out=get_param(obj.ModelHandle,'Name');
        end
        function delete(obj)
            obj.view=[];
        end
    end
    methods(Static)
        function refresh(mdlH,inserted,deleted,modified,modifiedUUIDs)
            v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(mdlH);
            if~isempty(v)
                if isa(v.ViewSource,'simulinkcoder.internal.app.SDPViewSource')
                    v.ViewSource.refreshFromListener(inserted,deleted,modified,modifiedUUIDs);
                end
            end
        end
    end
end


