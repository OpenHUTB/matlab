function matchingConfigs=getMatchingConfigs(lTargetRegistry,configs,configInterface,mexCompInfo)





    refreshConfig(lTargetRegistry)

    if nargin<2
        DAStudio.error('RTW:targetRegistry:invalidNumInput');
    end


    isModelUsingToolchainInfo=configInterface.isToolchainBased...
    ('MexCompilerInfo',mexCompInfo);

    if isModelUsingToolchainInfo

        useToolchainCriteria=true;
        matchingConfigs=locGetMatchingConfigs(configs,configInterface,useToolchainCriteria);

    else

        useToolchainCriteria=false;
        matchingConfigs=locGetMatchingConfigs(configs,configInterface,useToolchainCriteria);
    end


    function matchingConfigs=locGetMatchingConfigs(configs,configInterface,useToolchainCriteria)


        numConfigs=length(configs);

        keepIndices=ones(1,numConfigs);
        for configIdx=1:numConfigs
            config=configs(configIdx);


            if~isempty(config.SystemTargetFile)
                if~any(strcmp(config.SystemTargetFile,configInterface.getParam('SystemTargetFile')))
                    keepIndices(configIdx)=0;
                end
            end

            if useToolchainCriteria
                if isempty(config.Toolchain)
                    if~isempty(config.TemplateMakefile)

                        keepIndices(configIdx)=0;
                    end
                else
                    if~any(strcmp(config.Toolchain,configInterface.getParam('Toolchain')))
                        keepIndices(configIdx)=0;
                    end
                end
            else
                if isempty(config.TemplateMakefile)
                    if~isempty(config.Toolchain)

                        keepIndices(configIdx)=0;
                    end
                else
                    if strcmp(configInterface.getParam('GenerateMakefile'),'on')

                        if~any(strcmp(config.TemplateMakefile,configInterface.getParam('TemplateMakefile')))
                            keepIndices(configIdx)=0;
                        end
                    else

                        keepIndices(configIdx)=0;
                    end
                end
            end


            if~isempty(config.TargetHWDeviceType)
                anyHWMatches=false;
                for i=1:length(config.TargetHWDeviceType)
                    currDeviceType=config.TargetHWDeviceType{i};
                    if target.internal.isHWDeviceTypeEq(currDeviceType,configInterface.getParam('TargetHWDeviceType'))
                        anyHWMatches=true;
                        break;
                    end
                end
                if~anyHWMatches
                    keepIndices(configIdx)=0;
                end
            end


            if~isempty(config.HardwareBoard)
                if~any(strcmp(config.HardwareBoard,codertarget.target.getHardwareName(configInterface.getConfig)))
                    keepIndices(configIdx)=0;
                end
            end


            if~isempty(config.isConfigSetCompatibleFcn)

                try
                    isConfigSetCompatible=config.isConfigSetCompatibleFcn(configInterface);
                catch e
                    isConfigSetCompatible=false;
                    MSLDiagnostic('RTW:targetRegistry:badIsConfigSetCompatibleFcnWarning',...
                    config.ConfigName,...
                    e.getReport('basic')).reportAsWarning;
                end
                if~isConfigSetCompatible
                    keepIndices(configIdx)=0;
                end
            end


        end
        matchingConfigs=configs(logical(keepIndices));



