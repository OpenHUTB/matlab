function connectivityConfigs=getConnectivityConfigs(lTargetRegistry,cs,mexCompInfo)





    refreshConfig(lTargetRegistry)

    if nargin<1
        DAStudio.error('RTW:targetRegistry:invalidNumInput');
    end


    connectivityConfigs=lTargetRegistry.ConnectivityConfigs;

    if nargin>=2

        if nargin<3
            mexCompInfo=coder.make.internal.getMexCompilerInfo();
        end


        expectedType='coder.connectivity.ConfigInterface';
        if~isa(cs,expectedType)
            DAStudio.error('RTW:targetRegistry:invalidInputType',expectedType);
        end

        if~isempty(connectivityConfigs)
            connectivityConfigs=coder.internal.getMatchingConfigs...
            (lTargetRegistry,connectivityConfigs,cs,mexCompInfo);
        end
    end


