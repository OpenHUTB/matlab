function toolChainConfiguration=vdspDecorator(data)




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

    function flags=codeGenCompilerFlagsOverride(~,codeGenFlags,~)

        flags=linkfoundation.xmakefile.normalizeFlags(codeGenFlags);
    end

    function flags=codeGenLinkerFlagsOverride(~,codeGenFlags,~)
        flags='';
        if(isempty(codeGenFlags))
            return;
        end


        names=regexp(codeGenFlags,'.*(?<procSpec>\-proc\s+[\-\w]+\s).*','names','warnings');
        if(~isempty(names))
            codeGenFlags=regexprep(codeGenFlags,names.procSpec,'');
        end


        if(~isempty(codeGenFlags))
            tokens=textscan(codeGenFlags,'%s','MultipleDelimsAsOne',1);
            entries=tokens{1,1};
            for index=1:length(entries)
                if(isempty(flags))
                    flags=sprintf('-flags-link %s',entries{index});
                else
                    flags=sprintf('%s,%s',flags,entries{index});
                end
            end
        end


        if(~isempty(names))
            flags=sprintf('%s %s',names.procSpec,flags);
        end

        flags=linkfoundation.xmakefile.normalizeFlags(flags);
    end

end