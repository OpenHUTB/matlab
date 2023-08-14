function newToolchain=updateToolchainOnHardwareBoardUpdate(cs)






    newToolchain='';
    cs=cs.getConfigSet;
    if isempty(cs)
        return;
    end

    isToolchain=configset.internal.custom.getToolchainApproach(cs);
    if isToolchain
        adp=configset.internal.getConfigSetAdapter(cs);



        adp.toolchainInfo=[];
        configset.internal.customwidget.ToolchainValues(cs,'Toolchain',0);
        if~isempty(adp.toolchainInfo)
            if(adp.toolchainInfo.TcGroup~=coder.make.enum.ToolchainGroup.BOARD_ASSOCIATED)




                boardToolchains=adp.toolchainInfo.TcNameList(...
                adp.toolchainInfo.TcGroupList==coder.make.enum.ToolchainGroup.BOARD_ASSOCIATED);
                if~isempty(boardToolchains)


                    newToolchain=boardToolchains{1};
                    return;
                end
            end
            if~adp.toolchainInfo.TcFound



                newToolchain=coder.make.internal.getInfo('default-toolchain');
            end
        end
    end
