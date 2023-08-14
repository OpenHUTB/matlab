



classdef SDPDataDictionaryViewSource<simulinkcoder.internal.app.DataDictionaryViewSource&simulinkcoder.internal.app.SDPViewSource
    properties
m_dd
        isLocalDict='false';
    end
    methods
        function obj=SDPDataDictionaryViewSource(ddName,isAttachedToModel,modelHandle)
            obj=obj@simulinkcoder.internal.app.DataDictionaryViewSource(ddName,isAttachedToModel,modelHandle);
            obj.m_dd=Simulink.dd.open(obj.DataDictionaryFileName);
            obj.m_source=obj.DataDictionaryFileName;
            obj.initCoderDictContainer();
        end
        function initCoderDictContainer(obj)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            if coder.dictionary.exist(obj.DataDictionaryFileName)
                cdict=hlp.openDD(obj.DataDictionaryFileName);
                obj.m_cdefinition=cdict;
                obj.m_container=cdict.owner;
                coderdictionary.data.api.startChangeTracking(cdict.owner);
            end
        end

        function setupInterface(obj,type)
            coder.dictionary.create(obj.m_source,type);
            obj.initCoderDictContainer();
        end
        function onBrowserClose(obj,size)
            onBrowserClose@simulinkcoder.internal.app.DataDictionaryViewSource(obj,size);
            obj.unsubscribe();
        end
        function onSourceBeingDestroyed(obj,~,~,~)
            onSourceBeingDestroyed@simulinkcoder.internal.app.ViewSourceBase(obj);
            obj.m_dd.close;
            obj.ddConn.close;
            simulinkcoder.internal.app.DictionaryViewManager.instance.removeView(obj.DataDictionaryFileName);
        end
        function fileName=NativePlatformNavFileName(~)
            fileName='SDP_nativecomponent.json';
        end
        function saveButtonCallback(obj)
            dd=Simulink.data.dictionary.open(obj.DataDictionaryFileName);
            try
                dd.saveChanges;
            catch e

                if strcmp(e.identifier,'MATLAB:save:permissionDenied')
                    msg.clientID=obj.ClientID;
                    msg.messageID='updateFailure_SDP';
                    msg.msg=e.message;
                    msg.errTitle=e.identifier;
                    message.publish(obj.Channel,msg);
                end
            end
        end

        function ret=isDisabled(obj,dataProp)


            ret=false;
            try
                ret=~strcmp(obj.m_cdefinition.owner.ID,dataProp.DataSource);
            catch me

                if~strcmp(me.identifier,'MATLAB:noSuchMethodOrField')
                    rethrow(me)
                end
            end
        end
        function delete(obj)
            obj.unsubscribe;
            if isa(obj.m_dd,'Simulink.data.dictionary')
                obj.m_dd.close;
            end
        end
    end
end


