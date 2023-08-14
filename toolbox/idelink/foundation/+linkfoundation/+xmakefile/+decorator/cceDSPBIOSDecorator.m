function toolChainConfiguration=cceDSPBIOSDecorator(data)




    toolChainConfiguration=linkfoundation.xmakefile.decorator.cceDecorator(data);


    toolChainConfiguration.SourceFilesOverride=@sourceFilesOverride;
    toolChainConfiguration.LibraryFilesOverride=@libraryFilesOverride;
    toolChainConfiguration.SkippedFilesOverride=@skippedFilesOverride;
    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;


    toolChainConfiguration.OnContextChangeCallback=@onContextChangeCallback;





    toolChainConfiguration.Operational=linkfoundation.xmakefile.validateRequiredDirectories(toolChainConfiguration);


    function onContextChangeCallback(src,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.VALIDATE_REQUIRED_ENVIRONMENT,data.Context))
            src.Operational=false;
            src.Operational=linkfoundation.xmakefile.validateRequiredDirectories(src,true);
        end
    end


    function files=sourceFilesOverride(src,codeGenFiles,~)
        files=linkfoundation.xmakefile.replaceFileNameWithSpaces(codeGenFiles);
        if(src.PrebuildEnable)


            files{end+1}='[|||MW_XMK_SOURCE_PATH_REF|||][|||MW_XMK_MODEL_NAME|||]cfg.s62';
            files{end+1}='[|||MW_XMK_SOURCE_PATH_REF|||][|||MW_XMK_MODEL_NAME|||]cfg_c.c';
        end
    end


    function files=libraryFilesOverride(~,codeGenFiles,data)
        rtsLibPattern='rts[\w]+\.lib';
        rtsLibWithCCSv3RelPath=['cgtools\\lib\\',rtsLibPattern];
        cslLibPattern='csl[\w]+\.lib';
        cslLibWithCCSv3RelPath=['\\csl\\lib\\',cslLibPattern];

        files={};
        for index=1:length(codeGenFiles)


            if(regexpi(codeGenFiles{index},rtsLibWithCCSv3RelPath))
                continue;
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


            if regexpi(codeGenFiles{index},'\\xdctools\\packages\\ti\\catalog\\c6000\\[\w]+\.[\w]+');
                xdcIndex=regexpi(codeGenFiles{index},'packages\\ti\\catalog\\c6000\\[\w]+\.[\w]+');
                xdcFile=codeGenFiles{index}(xdcIndex:end);
                xdcToolsDir=linkfoundation.xmakefile.XMakefilePreferences.getXDCToolsInstallLocation().Path;
                codeGenFiles{index}=fullfile(xdcToolsDir,xdcFile);
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


    function files=skippedFilesOverride(~,codeGenFiles,~)


        files={};
        for index=1:length(codeGenFiles)
            if(isa(codeGenFiles{index},'linkfoundation.util.File'))
                file=codeGenFiles{index};
            else
                file=linkfoundation.util.File(codeGenFiles{index});
            end
            if(~regexp(file.Extension,'tcf'))
                files{end+1}=file.FullPathName;%#ok
            end
        end
    end


    function flags=codeGenLinkerFlagsOverride(~,codeGenFlags,data)
        if(strcmpi(linkfoundation.xmakefile.XMakefileConfigurationEvent.EXECUTABLE_TARGET_BEFORE_BUILD,data.Context))

            codeGenFlags=regexprep(codeGenFlags,'\<\-o\s*("[^"]+"|[^ ]+)','');

            codeGenFlags=regexprep(codeGenFlags,'-l"rts[\w]+\.lib"','');

            flags='-z';
            cslLibLoc=linkfoundation.xmakefile.XMakefilePreferences.getC6000CSLLibPathOptional();
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
