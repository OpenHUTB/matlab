function removeConnectivityConfigs(lTargetRegistry,configToKeep)








    refreshConfig(lTargetRegistry)

    if nargin<1
        DAStudio.error('RTW:targetRegistry:invalidNumInput');
    end

    if nargin<2
        configToKeep=[];
    end



    connectivityConfigs=lTargetRegistry.ConnectivityConfigs;

    numConfigs=length(connectivityConfigs);

    keepIndices=ones(1,numConfigs);
    for configIdx=1:numConfigs
        config=connectivityConfigs(configIdx);


        if~isempty(config.ConfigName)
            if~strcmp(config.ConfigName,configToKeep)
                keepIndices(configIdx)=0;
            end
        end
    end

    removeConnectivityConfig(lTargetRegistry,~keepIndices);

