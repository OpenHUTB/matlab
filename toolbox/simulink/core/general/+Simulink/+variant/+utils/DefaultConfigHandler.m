classdef(Sealed,Hidden)DefaultConfigHandler<handle





    properties(SetAccess=private)

        mSysName(1,:)char;

        mDefaultConfigurationName(1,:)char;
    end


    methods(Access={?Simulink.variant.reducer.Environment,?vmgrcfgplugin.VariantConfigurationManager,?mwslvariants.configutils.DefaultConfigTestHandler})

        function obj=DefaultConfigHandler(sysName)

            obj.mSysName=sysName;
            obj.mDefaultConfigurationName=obj.getDefaultConfiguration();


            obj.setDefaultConfiguration('');
        end

        function delete(obj)

            if bdIsLoaded(obj.mSysName)
                obj.setDefaultConfiguration(obj.mDefaultConfigurationName);
            end
        end

    end

    methods(Access=private)

        function defConfig=getDefaultConfiguration(obj)
            defConfig='';
            vcdObjName=get_param(obj.mSysName,'VariantConfigurationObject');

            if isempty(vcdObjName)
                return;
            end

            try
                warnStateDC=warning('off','Simulink:VariantManager:DefaultConfigurationRemoved');
                warnStateSMC=warning('off','Simulink:VariantManager:SubModelConfigsRemoved');
                warnStateDCCleanup=onCleanup(@()warning(warnStateDC));
                warnStateSMCCleanup=onCleanup(@()warning(warnStateSMC));
                defConfig=evalinConfigurationsScope(obj.mSysName,[vcdObjName,'.DefaultConfigurationName']);
            catch ex %#ok<NASGU>
            end
        end

        function setDefaultConfiguration(obj,config)
            vcdObjName=get_param(obj.mSysName,'VariantConfigurationObject');

            if isempty(vcdObjName)||isempty(obj.mDefaultConfigurationName)
                return;
            end

            try
                warnStateDC=warning('off','Simulink:VariantManager:DefaultConfigurationRemoved');
                warnStateSMC=warning('off','Simulink:VariantManager:SubModelConfigsRemoved');
                warnStateDCCleanup=onCleanup(@()warning(warnStateDC));
                warnStateSMCCleanup=onCleanup(@()warning(warnStateSMC));
                evalinConfigurationsScope(obj.mSysName,[vcdObjName,...
                '.setDefaultConfigurationName(''',...
                config,''')']);
            catch ex %#ok<NASGU>
            end

        end

    end

end


