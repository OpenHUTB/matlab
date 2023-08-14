



classdef NewDataDictionaryViewSource<simulinkcoder.internal.app.SDPViewSource
    properties
        m_dd=[]
        ddConn=[]
        isLocalDict='false';
        CreateAndSave=false;
    end
    events
HandleBeingDestroyed
SlddFileSelected
    end
    methods
        function obj=NewDataDictionaryViewSource()
            obj.m_source='';
            obj.m_container=[];
            obj.m_cdefinition=[];
        end
        function onSourceBeingDestroyed(obj,~,~,~)

            obj.notify('HandleBeingDestroyed');
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(-1);
        end
        function notifySlddFileSelected(obj,filePath)
            obj.notify('SlddFileSelected',simulinkcoder.internal.app.SlddFileSelectedEventData(filePath));
        end
        function fileName=NativePlatformNavFileName(~)
            fileName='SDP_nativecomponent.json';
        end
        function saveButtonCallback(~)
        end

        function ret=isDisabled(~,~)
            ret=false;
        end
        function out=getClientAssociationHandle(~)
            out=-1;
        end
        function onBrowserClose(obj,size)
            simulinkcoder.internal.app.View.getSetGeometry(size);
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(-1);
            obj.unsubscribe();
        end
        function out=CoderDataSourceName(~)
            out='UNKNOWN';
        end
        function delete(obj)
            obj.unsubscribe;
        end
        function createListener(~,~)
        end
    end
    methods(Static)
        function refresh(~,~,~,~,~)
        end
    end
end

