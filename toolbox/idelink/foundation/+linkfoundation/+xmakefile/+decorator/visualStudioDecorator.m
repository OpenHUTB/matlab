function toolChainConfiguration=visualStudioDecorator(data)




    toolChainConfiguration=data;

    toolChainConfiguration.CodeGenCompilerFlagsOverride=@codeGenCompilerFlagsOverride;
    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;

    function flags=codeGenCompilerFlagsOverride(~,codeGenFlags,~)
        codeGenFlags=strrep(codeGenFlags,'"','');
        flags=linkfoundation.xmakefile.normalizeFlags(codeGenFlags);
    end

    function flags=codeGenLinkerFlagsOverride(~,codeGenFlags,~)
        codeGenFlags=strrep(codeGenFlags,'"','');
        flags=linkfoundation.xmakefile.normalizeFlags(codeGenFlags);
    end


    toolChainConfiguration.OnContextChangeCallback=@onContextChangeCallback;


    toolChainConfiguration.Operational=linkfoundation.xmakefile.validateRequiredDirectories(toolChainConfiguration);

    function onContextChangeCallback(src,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.VALIDATE_REQUIRED_ENVIRONMENT,data.Context))
            src.Operational=linkfoundation.xmakefile.validateRequiredDirectories(src,true);
        end
    end

end
