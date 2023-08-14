classdef(Sealed)CoderConfigProducer<coderapp.internal.config.util.CompositeProducer




    methods
        function this=CoderConfigProducer()
            this@coderapp.internal.config.util.CompositeProducer('coder.config',...
            'ExcludeKeys',{'boundConfig','useEmbeddedCoder','gpuEnabled'},...
            'BoundObjectKey','boundConfig','ScriptVariable','cfg');
        end
    end

    methods(Access=protected)
        function cfg=instantiate(this)
            [factory,buildType,useEmbeddedCoder,isFiaccel]=this.analyzeState();
            cfg=factory(buildType,'ecoder',useEmbeddedCoder,'code',~isFiaccel);
        end

        function updateScript(this)
            [factory,buildType,useEmbeddedCoder,isFiaccel]=this.analyzeState();
            if isFiaccel
                args={"code",false};
            elseif buildType~="MEX"
                args={"ecoder",useEmbeddedCoder};
            else
                args={};
            end
            this.ScriptHelper.setInstantiator(factory,[{string(lower(buildType))},args]);
        end

        function imported=postImport(this,cfg,imported)
            if isempty(imported)
                return
            end
            if isprop(cfg,'Hardware')&&isempty(cfg.Hardware)
                if~isempty(cfg.HardwareImplementation)
                    if cfg.HardwareImplementation.ProdEqTarget
                        deviceType=cfg.HardwareImplementation.ProdHWDeviceType;
                    else
                        deviceType=cfg.HardwareImplementation.TargetHWDeviceType;
                    end
                else
                    deviceType='Generic->MATLAB Host Computer';
                end
                if deviceType=="Generic->MATLAB Host Computer"
                    imported.hardwareName=coderapp.internal.hw.HardwareConfigController.HW_MATLAB;
                else
                    imported.hardwareName=coderapp.internal.hw.HardwareConfigController.HW_NONE;
                end
            end
            switch class(cfg)
            case{'coder.EmbeddedCodeConfig','coder.CodeConfig'}
                imported.buildType=cfg.OutputType;
            case{'coder.MexCodeConfig','coder.MexConfig'}
                imported.buildType='MEX';
            end
            if isprop(cfg,'OutputType')
                imported.buildType=cfg.OutputType;
            else
                imported.buildType='MEX';
            end
            if isfield(imported,'targetLang')&&isprop(cfg,'DeepLearningConfig')&&~isempty(cfg.DeepLearningConfig)&&...
                cfg.DeepLearningConfig.TargetLibrary~="none"&&~isempty(this.value('boundConfig'))



                imported=rmfield(imported,'targetLang');
            end
        end

        function reuse=canReuse(this)
            config=this.Production;
            [buildType,useEmbeddedCoder]=this.value('buildType','useEmbeddedCoder');
            if isa(config,'coder.MexCodeConfig')||isa(config,'coder.MexConfig')
                reuse=buildType=="MEX";
            else
                reuse=buildType~="MEX";
            end
            reuse=reuse&&(useEmbeddedCoder~=any(strcmp(class(config),...
            {'coder.MexConfig','coder.CodeConfig'})));
        end

        function production=updateProperties(this,production,keys,rebaseline)
            production=updateProperties@coderapp.internal.config.util.CompositeProducer(this,production,keys,rebaseline);

            if ismember('hardware',keys)&&~isempty(this.value('hardware'))


                try
                    production.Hardware=production.Hardware;
                catch
                    return
                end
                if~this.Importing


                    this.requestImport(production,false,false);
                end
            end
        end
    end

    methods(Access=private)
        function[factory,buildType,useEmbeddedCoder,isFiaccel,gpuEnabled,boundConfig]=analyzeState(this)
            [buildType,useEmbeddedCoder,gpuEnabled,isFiaccel,boundConfig]=this.value(...
            'buildType','useEmbeddedCoder','gpuEnabled','x_isFiaccel','boundConfig');
            if gpuEnabled
                factory=@coder.gpuConfig;
            else
                factory=@coder.config;
            end
        end
    end
end
