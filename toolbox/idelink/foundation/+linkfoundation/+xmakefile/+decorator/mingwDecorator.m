function toolChainConfiguration=mingwDecorator(data)




    toolChainConfiguration=data;


    toolChainConfiguration.CodeGenCompilerFlagsOverride=@codeGenCompilerFlagsOverride;
    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;
    toolChainConfiguration.LinkerLineOverride=@linkerLineOverride;

    toolChainConfiguration.OnContextChangeCallback=@onContextChangeCallback;


    toolChainConfiguration.Operational=linkfoundation.xmakefile.validateRequiredDirectories(toolChainConfiguration);

    function onContextChangeCallback(src,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.VALIDATE_REQUIRED_ENVIRONMENT,data.Context))
            src.Operational=linkfoundation.xmakefile.validateRequiredDirectories(src,true);
        end
    end

    function flags=codeGenCompilerFlagsOverride(~,codeGenFlags,~)

        flags=linkfoundation.xmakefile.normalizeFlags(codeGenFlags);
    end

    function flags=codeGenLinkerFlagsOverride(src,codeGenFlags,data)
        adjFlags=codeGenFlags;
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD,data.Context))



            names=regexp(codeGenFlags,'\s+\-l(?<lib>\w+)','names');
            if(~isempty(names))
                for index=1:length(names)
                    src.LinkerFlags=sprintf('%s -l%s',src.LinkerFlags,names(index).lib);
                end

                adjFlags=regexprep(codeGenFlags,'\s+\-l\w+','');
            end
        end
        flags=linkfoundation.xmakefile.normalizeFlags(adjFlags);
    end

    function line=linkerLineOverride(~,data)
        line='';



        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD,data.Context))
            line=['"[|||MW_XMK_LINKER_REF|||]" '...
            ,'[|||MW_XMK_LINKER_CODEGEN_REF|||] [|||MW_XMK_OBJECT_FILES_REF|||] '...
            ,'[|||MW_XMK_LIBRARY_FILES_REF|||] [|||MW_XMK_LINKER_TCCFG_REF|||]'];
        end
    end
end