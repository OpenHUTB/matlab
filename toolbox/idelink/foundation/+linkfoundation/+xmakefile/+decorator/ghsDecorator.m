function toolChainConfiguration=ghsDecorator(data)




    toolChainConfiguration=data;


    toolChainConfiguration.CodeGenCompilerFlagsOverride=@codeGenCompilerFlagsOverride;
    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;

    toolChainConfiguration.OnContextChangeCallback=@onContextChangeCallback;


    toolChainConfiguration.Operational=linkfoundation.xmakefile.validateRequiredDirectories(toolChainConfiguration);

    function onContextChangeCallback(src,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.VALIDATE_REQUIRED_ENVIRONMENT,data.Context))
            src.Operational=linkfoundation.xmakefile.validateRequiredDirectories(src,true);
        end
    end

    function flags=codeGenCompilerFlagsOverride(src,codeGenFlags,~)
        flags='';
        if(isempty(codeGenFlags))
            return;
        end

        flags=linkfoundation.xmakefile.normalizeFlags(codeGenFlags);


        copyFlags='';
        names=regexp(flags,'\-bsp\s*=\s*(?<bsp_spec>[\S]+)','names','once');
        if(~isempty(names))
            copyFlags=sprintf('-bsp=%s',names(1).bsp_spec);
        end
        names=regexp(flags,'\-cpu\s*=\s*(?<cpu_spec>[\S]+)','names','once');
        if(~isempty(names))
            copyFlags=sprintf('%s -cpu=%s',copyFlags,names(1).cpu_spec);
        end
        if(~isempty(copyFlags))


            src.LinkerFlags=[copyFlags,' ',src.LinkerFlags];
        end
    end

    function flags=codeGenLinkerFlagsOverride(~,codeGenFlags,~)

        flags=linkfoundation.xmakefile.normalizeFlags(codeGenFlags);
    end

end