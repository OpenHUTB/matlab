function invokeDownloader(modelName,hCS,toolchainInfo,exeFile)




    toolchainName=get_param(hCS,'Toolchain');
    if isequal(toolchainName,coder.make.internal.getInfo('default-toolchain'))
        toolchainName=codertarget.utils.getDefaultToolchainName();
    end

    if codertarget.utils.isMdlConfiguredForSoC(hCS)
        soc.internal.customoperatingsystem.isCompatible(modelName);
    end

    toolchain=coder.make.internal.getToolchainInfoFromRegistry(toolchainName);
    try
        useToolchainToDownload=~toolchainInfo.IsLoadCommandMATLABFcn...
        &&toolchain.PostbuildTools.isKey('Download');
        if~useToolchainToDownload
            loadCommand=toolchainInfo.LoadCommand;
            try


                arguments=eval(toolchainInfo.LoadCommandArgs);
            catch
                arguments=toolchainInfo.LoadCommandArgs;
            end
            hardwareName=codertarget.data.getParameterValue(hCS,'TargetHardware');
            if toolchainInfo.IsLoadCommandMATLABFcn
                feval(loadCommand,arguments,exeFile,hardwareName);
            else
                system(loadCommand,arguments,exeFile,hardwareName);
            end
        end
    catch ex
        DAStudio.error('codertarget:build:DownloadCallbackError',char([10,ex.message]));
    end
end