function toolChainConfiguration=ccsDecorator(data)




    toolChainConfiguration=data;


    toolChainConfiguration.SourceFilesOverride=@sourceFilesOverride;
    toolChainConfiguration.HeaderFilesOverride=@headerFilesOverride;
    toolChainConfiguration.LibraryFilesOverride=@libraryFilesOverride;
    toolChainConfiguration.CodeGenCompilerFlagsOverride=@codeGenCompilerFlagsOverride;
    toolChainConfiguration.PrivateData.BaseCodeGenLinkerFlagsOverride=@baseCodeGenLinkerFlagsOverride;


    toolChainConfiguration.OnContextChangeCallback=@onContextChangeCallback;




    toolChainConfiguration.Operational=linkfoundation.xmakefile.validateRequiredDirectories(toolChainConfiguration);


    function onContextChangeCallback(src,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.VALIDATE_REQUIRED_ENVIRONMENT,data.Context))
            src.Operational=linkfoundation.xmakefile.validateRequiredDirectories(src,true);
        end
    end


    function files=sourceFilesOverride(~,codeGenFiles,~)



        tempDirPresent=getenv('TMP');
        if linkfoundation.util.isUnsafePathName(tempDirPresent)
            msg='<a href="matlab:linkfoundation.util.changeTMP">clicking here</a>';
            linkfoundation.xmakefile.raiseException(message('ERRORHANDLER:xmakefile:BadTMPDir',msg));
        end
        files=linkfoundation.xmakefile.replaceFileNameWithSpaces(codeGenFiles);
    end


    function files=headerFilesOverride(~,codeGenFiles,~)
        files=linkfoundation.xmakefile.replaceFileNameWithSpaces(codeGenFiles);
    end


    function files=libraryFilesOverride(~,codeGenFiles,data)
        files=linkfoundation.xmakefile.replaceFileNameWithSpaces(codeGenFiles);

        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.ARCHIVE_TARGET_BEFORE_BUILD,data.Context)||...
            strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD,data.Context))
            for i=1:numel(files)
                fileobj=linkfoundation.util.File(files{i});
                if(fileobj.isUNCPath())
                    files{i}=fileobj.EscapedFullPathName;
                end
            end
        end
    end


    function flags=codeGenCompilerFlagsOverride(~,codeGenFlags,~)



        flags=linkfoundation.xmakefile.normalizeFlags(regexprep(codeGenFlags,'(\-|\\)fr\s*("[^"]+"|[^ ]+)',''));
    end


    function flags=baseCodeGenLinkerFlagsOverride(~,codeGenFlags,data,proc)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD,data.Context))

            codeGenFlags=regexprep(codeGenFlags,'\<\-o\s*("[^"]+"|[^ ]+)','');

            flags='-z';

            cgtLibLoc=linkfoundation.xmakefile.XMakefilePreferences.getCGToolsLibPath(proc);
            if~isempty(cgtLibLoc)
                cgtLibLoc=linkfoundation.util.Location.convertToUnixPath(cgtLibLoc.Path);
                flags=sprintf('%s %s',flags,['-I"',cgtLibLoc(1:end-1),'"']);
            end
            cslLibLoc=linkfoundation.xmakefile.XMakefilePreferences.getCSLLibPath(proc);
            if~isempty(cslLibLoc)
                cslLibLoc=linkfoundation.util.Location.convertToUnixPath(cslLibLoc.Path);
                flags=sprintf('%s %s',flags,['-I"',cslLibLoc(1:end-1),'"']);
            end

            flags=sprintf('%s %s',flags,codeGenFlags);
            flags=linkfoundation.xmakefile.normalizeFlags(flags);
        else

            flags='';
        end
    end
end