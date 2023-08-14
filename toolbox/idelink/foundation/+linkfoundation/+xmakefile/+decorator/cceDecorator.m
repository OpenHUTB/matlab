function toolChainConfiguration=cceDecorator(data)




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



        files=linkfoundation.xmakefile.replaceFileNameWithSpaces(codeGenFiles);
    end


    function files=headerFilesOverride(~,codeGenFiles,~)
        files=linkfoundation.xmakefile.replaceFileNameWithSpaces(codeGenFiles);
    end


    function files=libraryFilesOverride(~,codeGenFiles,data)

        rtsLibPattern='rts[\w]+\.lib';
        rtsLibWithCCSv3RelPath=['\\cgtools\\lib\\',rtsLibPattern];
        cslLibPattern='csl[\w]+\.lib';
        cslLibWithCCSv3RelPath=['\\csl\\lib\\',cslLibPattern];

        files={};
        for index=1:length(codeGenFiles)


            if(regexpi(codeGenFiles{index},rtsLibWithCCSv3RelPath))
                start=regexpi(codeGenFiles{index},rtsLibPattern);
                rtsLibFile=codeGenFiles{index}(start:end);
                proc=regexpi(codeGenFiles{index},['\\(?<family>\w+)',rtsLibWithCCSv3RelPath],'names');
                if isempty(proc)
                    proc=regexpi(codeGenFiles{index},['(?<family>\w+)',rtsLibWithCCSv3RelPath],'names');
                    if isempty(proc)
                        DAStudio.error('ERRORHANDLER:xmakefile:xmk_warning_Functions_CGToolsInstallDir_UnableToDetermineProcessor');
                    end
                end
                codeGenFiles{index}=fullfile(...
                linkfoundation.xmakefile.XMakefilePreferences.(['get',upper(proc.family),'CGToolsInstallLocation'])().Path,...
                'lib',rtsLibFile);
            end


            if(regexpi(codeGenFiles{index},cslLibWithCCSv3RelPath))
                start=regexpi(codeGenFiles{index},cslLibPattern);
                cslLibFile=codeGenFiles{index}(start:end);

                proc=regexpi(codeGenFiles{index},['\\(?<family>\w+)',cslLibWithCCSv3RelPath],'names');
                if isempty(proc)
                    proc=regexpi(codeGenFiles{index},['(?<family>\w+)',cslLibWithCCSv3RelPath],'names');
                    if isempty(proc)
                        DAStudio.error('ERRORHANDLER:xmakefile:xmk_warning_Functions_CSLInstallDir_UnableToDetermineProcessor');
                    end
                end
                cslLibDir=linkfoundation.xmakefile.XMakefilePreferences.(['get',upper(proc.family),'CSLInstallLocation'])().Path;


                libSubfolders=dir(fullfile(cslLibDir,'lib*'));
                lib=[];
                for i=1:numel(libSubfolders)
                    if libSubfolders(i).isdir
                        lib=libSubfolders(i).name;
                        break;
                    end
                end
                if isempty(lib)
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_Functions_CSLInstallDir_MissingLibSubfolder').reportAsWarning;
                    continue;
                else
                    cslLibDir=fullfile(cslLibDir,lib);
                end
                codeGenFiles{index}=fullfile(cslLibDir,cslLibFile);
            end


            files{end+1}=codeGenFiles{index};%#ok
        end

        files=linkfoundation.xmakefile.replaceFileNameWithSpaces(files);


        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.ARCHIVE_TARGET_BEFORE_BUILD,data.Context)||...
            strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD,data.Context))
            for i=1:numel(files)
                fileobj=linkfoundation.util.File(files{i});
                if(fileobj.isUNCPath())
                    files{i}=linkfoundation.util.Location.convertToUnixPath(fileobj.EscapedFullPathName);
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


            cgtLibLoc=linkfoundation.xmakefile.XMakefilePreferences.getCGToolsLibPathForCCSv4(proc);
            if~isempty(cgtLibLoc)
                cgtLibLoc=linkfoundation.util.Location.convertToUnixPath(cgtLibLoc.Path);
                flags=sprintf('%s %s',flags,['-I"',cgtLibLoc(1:end-1),'"']);
            end
            if strcmpi(proc,'c2000')
                cslLibLoc=[];
            else
                cslLibLoc=linkfoundation.xmakefile.XMakefilePreferences.getCSLLibPathForCCSv4(proc);
            end
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