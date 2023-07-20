function setToolChain(hObj,hwInfo)




    automaticallyLocateToolchain=coder.make.internal.getInfo('default-toolchain');
    validToolchains=[automaticallyLocateToolchain;coder.make.getToolchains()];
    targetHardwareToolchains={hwInfo.ToolChainInfo.Name};
    validTargetHardwareToolchains=intersect(targetHardwareToolchains,validToolchains,'stable');
    selectedToolchain=get_param(hObj.getConfigSet(),'Toolchain');
    [isToolchainFound,~]=ismember(selectedToolchain,validTargetHardwareToolchains);
    if isToolchainFound
        return;
    elseif~isempty(validTargetHardwareToolchains)
        set_param(hObj.getConfigSet(),'Toolchain',validTargetHardwareToolchains{1});
    else
        set_param(hObj.getConfigSet(),'Toolchain',automaticallyLocateToolchain);
    end

end