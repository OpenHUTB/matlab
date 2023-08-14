function emcRunPostCodeGenCommand(project,buildInfo,configInfo)



    pcgCommand='';
    if isprop(configInfo,'PostCodeGenCommand')
        pcgCommand=configInfo.PostCodeGenCommand;
    end
    if~isempty(pcgCommand)
        verbose=false;
        if isprop(configInfo,'Verbose')
            verbose=configInfo.Verbose;
        end
        emcPCGHook(project,buildInfo,pcgCommand,verbose);
    end
end
