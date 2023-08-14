



classdef SDPModelDictionaryViewSource<simulinkcoder.internal.app.ModelDictionaryViewSource&simulinkcoder.internal.app.SDPViewSource
    properties
m_dd
        isLocalDict='true';
    end
    methods
        function obj=SDPModelDictionaryViewSource(modelHandle)
            obj=obj@simulinkcoder.internal.app.ModelDictionaryViewSource(modelHandle);

            if~coder.dictionary.exist(modelHandle)
                coder.dictionary.create(modelHandle);
            end
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            cdict=hlp.openDD(obj.ModelHandle);
            obj.m_source=modelHandle;
            obj.m_cdefinition=cdict;
            obj.m_container=cdict.owner;
            coderdictionary.data.api.startChangeTracking(cdict.owner);
        end
        function onBrowserClose(obj,size)
            onBrowserClose@simulinkcoder.internal.app.ModelDictionaryViewSource(obj,size);
            obj.unsubscribe();
        end
        function fileName=NativePlatformNavFileName(~)
            fileName='SDP_modelNativePlatform.json';
        end
        function saveButtonCallback(obj)
            save_system(obj.ModelHandle);
        end
        function ret=isDisabled(obj,dataProp)


            ret=false;
            try
                ret=~strcmp(get_param(obj.m_source,'Name'),dataProp.DataSource);
            catch me

                if~strcmp(me.identifier,'MATLAB:noSuchMethodOrField')
                    rethrow(me)
                end
            end
        end
    end
end


