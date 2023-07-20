function toolChainConfiguration=eclipseDecorator(data)




    toolChainConfiguration=data;


    toolChainConfiguration.CodeGenCompilerFlagsOverride=@codeGenFlagsOverride;
    toolChainConfiguration.LinkerLineOverride=@linkerLineOverride;

    toolChainConfiguration.OnContextChangeCallback=@onContextChangeCallback;


    toolChainConfiguration.Operational=linkfoundation.xmakefile.validateRequiredDirectories(toolChainConfiguration);

    function onContextChangeCallback(src,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.VALIDATE_REQUIRED_ENVIRONMENT,data.Context))
            src.Operational=linkfoundation.xmakefile.validateRequiredDirectories(src,true);
        end
    end

    function flags=codeGenFlagsOverride(~,codeGenFlags,~)

        flags=linkfoundation.xmakefile.normalizeFlags(codeGenFlags);
    end

    function line=linkerLineOverride(~,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD,data.Context))
            line='"$(LINKER)" $(OBJ_FILES) $(LIBRARY_FILES) $(LINKER_ARGS)';
        else
            line='"$(LINKER)" $(LINKER_ARGS) $(OBJ_FILES) $(LIBRARY_FILES)';
        end
    end

end
