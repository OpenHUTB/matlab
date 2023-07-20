classdef ToolboxPreferencesManager<handle





    properties(SetAccess='private',GetAccess='public')
        GetPrefListener=[];
        SetPrefListener=[];
    end

    methods(Access='private')


        function obj=ToolboxPreferencesManager
            if usejava('jvm')&&~isdeployed
                jPrefPanel=javaMethodEDT('getPrefPanel','com.mathworks.toolbox.imaq.ImaqPrefPanel');

                getPrefCallback=handle(jPrefPanel.getGetPrefCallback());
                obj.GetPrefListener=...
                handle.listener(getPrefCallback,'delayed',@(src,data)obj.getPrefCalled());

                setPrefCallback=handle(jPrefPanel.getSetPrefCallback());
                obj.SetPrefListener=...
                handle.listener(setPrefCallback,'delayed',@(src,data)obj.setPrefCalled(data.JavaEvent));
            end

            try
                obj.loadPreferences();
            catch err %#ok<NASGU>
                if usejava('jvm')&&~isdeployed
                    jPrefs=obj.getPrefsFeaturesFromToolbox();
                    obj.setPrefsFeaturesInToolbox(jPrefs);
                end
            end
        end

        function prefs=getPrefsFeaturesFromToolbox(obj)%#ok<MANU>
            prefs=com.mathworks.toolbox.imaq.ImaqPrefStruct();
            prefObj=PreferencePanelProperties.getOrResetInstance();
            prefs.fGigeCommandPacketRetries=prefObj.getGigeCommandPacketRetries();
            prefs.fGigeHeartbeatTimeout=prefObj.getGigeHeartbeatTimeout();
            prefs.fGigePacketAckTimeout=prefObj.getGigePacketAckTimeout();
            prefs.fGigeDisableForceIP=prefObj.getGigeDisableForceIP();
            prefs.fMacvideoDiscoveryTimeout=prefObj.getMacvideoDiscoveryTimeout();
        end

        function getPrefCalled(obj)
            jPrefPanel=javaMethodEDT('getPrefPanel','com.mathworks.toolbox.imaq.ImaqPrefPanel');
            jPrefPanel.setPreferences(obj.getPrefsFeaturesFromToolbox());
        end

        function mPrefs=convertJavaPrefsToMATLABStruct(obj,jPrefs)%#ok<MANU>
            fNames=fields(jPrefs);
            for ii=1:length(fNames)
                mPrefs.(fNames{ii})=jPrefs.(fNames{ii});
            end
        end

        function jPrefs=convertMATLABStructToJavaPrefs(obj,mStruct)%#ok<MANU>
            jPrefs=com.mathworks.toolbox.imaq.ImaqPrefStruct();
            fNames=fields(jPrefs);
            for ii=1:length(fNames)
                jPrefs.(fNames{ii})=mStruct.(fNames{ii});
            end
        end

        function setPrefCalled(obj,prefs)
            mPrefs=obj.convertJavaPrefsToMATLABStruct(prefs);%#ok<NASGU>
            save(fullfile(prefdir,'imaqPreferences.mat'),'mPrefs');
            obj.setPrefsFeaturesInToolbox(prefs);
        end

        function setPrefsFeaturesInToolbox(obj,prefs)%#ok<MANU>
            prefObj=PreferencePanelProperties.getOrResetInstance();
            prefObj.setGigeCommandPacketRetries(prefs.fGigeCommandPacketRetries);
            prefObj.setGigeHeartbeatTimeout(prefs.fGigeHeartbeatTimeout);
            prefObj.setGigePacketAckTimeout(prefs.fGigePacketAckTimeout);
            prefObj.setGigeDisableForceIP(prefs.fGigeDisableForceIP);
            prefObj.setMacvideoDiscoveryTimeout(prefs.fMacvideoDiscoveryTimeout);
        end

    end

    methods(Access='public',Static=true)
        function singleObj=getOrResetInstance(reset)
            persistent localStaticObj;
            if(nargin==1)&&(reset==true)
                delete(localStaticObj);
                localStaticObj=[];
                singleObj=[];
            else
                if isempty(localStaticObj)||~isvalid(localStaticObj)
                    localStaticObj=ToolboxPreferencesManager;
                end
                singleObj=localStaticObj;
            end
        end
    end

    methods(Access='public')
        function loadPreferences(obj)
            mPrefs=[];
            load(fullfile(prefdir,'imaqPreferences.mat'));
            obj.setPrefsFeaturesInToolbox(mPrefs);
        end

    end

end

