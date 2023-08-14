



classdef DataDictionaryViewSource<simulinkcoder.internal.app.ViewSourceBase
    properties(Hidden=true)
        DataDictionaryFileName=[]


        ddClientListener=[]
        ddConn=[]
hModelCloseListener

        DefaultMappingViewSource=[]

        SDPViewSource=[]
        RTEViewSource=[]
    end
    methods
        function obj=DataDictionaryViewSource(ddName,isAttachedToModel,modelHandle)
            if~exist(ddName,'File')
                DAStudio.error('SimulinkCoderApp:core:DictionaryNotFound',ddName);
            end
            obj.DataDictionaryFileName=ddName;

            obj.isAttachedToModel=isAttachedToModel;
            if isAttachedToModel
                modelHandle=get_param(modelHandle,'handle');
                obj.ModelHandle=modelHandle;





                modelObject=get_param(modelHandle,'object');
                if~modelObject.hasCallback('PreClose','CoderDataUI_PreClose')
                    Simulink.addBlockDiagramCallback(modelHandle,'PreClose','CoderDataUI_PreClose',...
                    @obj.onSourceBeingDestroyed);
                end
            end
            obj.ddConn=Simulink.data.dictionary.open(obj.DataDictionaryFileName);
        end
        function createListener(obj,clientID)

            obj.ddClientListener=simulinkcoder.internal.app.DDClientListener(obj.ddConn,clientID);
        end
        function out=getClientAssociationHandle(obj)
            out=obj.DataDictionaryFileName;
        end
        function onBrowserClose(obj,size)
            simulinkcoder.internal.app.View.getSetGeometry(size);
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.DataDictionaryFileName);
        end
        function onSourceBeingDestroyed(obj,~,~,~)
            try
                onSourceBeingDestroyed@simulinkcoder.internal.app.ViewSourceBase(obj);
                simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.DataDictionaryFileName);
            catch
            end
        end
        function out=CoderDataSourceName(~)
            out='UNKNOWN';
        end
        function delete(obj)
            if~isempty(obj.ddConn)
                obj.ddConn.close;
            end
            if~isempty(obj.DefaultMappingViewSource)
                obj.DefaultMappingViewSource.delete;
                obj.DefaultMappingViewSource=[];
            end
            if~isempty(obj.SDPViewSource)
                obj.SDPViewSource.delete;
                obj.SDPViewSource=[];
            end
            if~isempty(obj.RTEViewSource)
                obj.RTEViewSource.delete;
                obj.RTEViewSource=[];
            end
        end
    end
    methods(Static)
        function refresh(ddFile,inserted,deleted,modified,modifiedUUIDs)
            if ischar(ddFile)

                ddFilePath=which(ddFile);
                if~isempty(ddFilePath)
                    ddFile=ddFilePath;
                end
            end
            v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView(ddFile);

            if isempty(v)
                [~,fname,fext]=fileparts(ddFile);
                v=simulinkcoder.internal.app.DictionaryViewManager.instance.getView([fname,fext]);
            end
            if~isempty(v)
                if isa(v.ViewSource,'simulinkcoder.internal.app.DataDictionaryViewSource')
                    defaultMappingViewSource=v.ViewSource.DefaultMappingViewSource;
                    if~isempty(defaultMappingViewSource)
                        defaultMappingViewSource.refreshUI();
                    end
                end
                if isa(v.ViewSource,'simulinkcoder.internal.app.SDPViewSource')
                    v.ViewSource.refreshFromListener(inserted,deleted,modified,modifiedUUIDs);
                end
            end
        end
    end
end


