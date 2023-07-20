classdef XMakefileTemplate<linkfoundation.util.File




    properties(Constant=true,Hidden=true)

        MakefileTemplateExtension='.mkt';


        WINDOWS='windows';
        MAC='mac'
        UNIX='unix';


        WIN32='win32';
        WIN64='win64';
        GLNX86='glnx86';
        GLNXA64='glnxa64';
        MACI='maci';
        MACI64='maci64';
        UNKNOWN='UNKNOWN';


        ON='on';
        OFF='off';


        TARGET_NONE='UNKNOWN';
        TARGET_BUILD='build';
        TARGET_EXECUTE='execute';
    end

    properties(Access='private')
        FileData='';
    end

    properties(Access='public')

        ModelName='';
        GeneratedFileName='';

        BuildConfiguration='';
        ToolChainConfiguration='';
        ToolChainConfigurationVersion='';

        BuildAction=linkfoundation.xmakefile.XMakefileTemplate.TARGET_NONE;

        SourcePath='';
        OutputPath='';
        DerivedPath='';

        MakeInclude='';

        ToolChainCompilerArgs='';
        CodeGenCompilerArgs='';
        CompilerPath='';

        ToolChainLinkerArgs='';
        CodeGenLinkerArgs='';
        LinkerPath='';

        PrebuildFeatureEnable=false;
        PrebuildArgs='';
        PrebuildPath='';

        PostbuildFeatureEnable=false;
        PostbuildArgs='';
        PostbuildPath='';

        ExecuteTargetFeatureEnable=false;
        ExecutePath='';
        ExecuteArgs='';

        SourceFiles={};
        HeaderFiles={};
        LibraryFiles={};
        SkippedFiles={};

        ObjectExtension='';
        TargetExtension='';
        TargetNamePrefix='';
        TargetNamePostfix='';

        Custom1='';
        Custom2='';
        Custom3='';
        Custom4='';
        Custom5='';

        PrebuildLineOverride='';
        CompilerLineOverride='';
        LinkerLineOverride='';
        PostbuildLineOverride='';
        ExecuteLineOverride='';
    end

    properties(GetAccess='public',SetAccess='private')
        IsSystemDefined=false;
    end

    properties(Dependent=true,Access='public')
Id
Version
GeneratedFileExtension



CurrentBuildActionIdentifier
BuildActionIdentifier
ExecuteActionIdentifier
GeneratedTargetIdentifier

OutputPathIdentifier
SourcePathIdentifier
DerivedPathIdentifier

CompilerCodeGenIdentifier
CompilerToolChainIdentifier
LinkerCodeGenIdentifier
LinkerToolChainIdentifier

PrebuildArgsIdentifier
PostbuildArgsIdentifier
ExecuteArgsIdentifier

SourceFilesIdentifier
HeaderFilesIdentifier
LibraryFilesIdentifier
ObjectFilesIdentifier
SkippedFilesIdentifier

CompilerToolIdentifier
LinkerToolIdentifier
PrebuildToolIdentifier
PostbuildToolIdentifier
ExecuteToolIdentifier
    end

    properties(Dependent=true,Access='private')
Content
    end

    methods(Access='public')








        function h=XMakefileTemplate(name)
            args={};
            if(0~=nargin)
                args{1}=name;
            end
            h=h@linkfoundation.util.File(args{:});


            userDir=linkfoundation.xmakefile.XMakefilePreferences.getUserConfigurationLocation();
            if(userDir==h)
                h.IsSystemDefined=false;
            else
                h.IsSystemDefined=true;
            end
        end




        function disp(h)
            if(h.IsSystemDefined),
                isSystemDefined=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_true');
            else
                isSystemDefined=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_false');
            end
            value='';
            value=sprintf('%sId = %s\n',value,h.Id);
            value=sprintf('%sIsSystemDefined = %s\n',value,isSystemDefined);
            value=sprintf('%sVersion = %s\n',value,h.Version);
            value=sprintf('%sModelName = %s\n',value,h.ModelName);
            value=sprintf('%sGeneratedFileName = %s\n',value,h.GeneratedFileName);
            value=sprintf('%sBuildConfiguration = %s\n',value,h.BuildConfiguration);
            value=sprintf('%sToolChainConfiguration = %s\n',value,h.ToolChainConfiguration);
            value=sprintf('%sToolChainConfigurationVersion = %s\n',value,h.ToolChainConfigurationVersion);
            value=sprintf('%sBuildAction = %s\n',value,h.BuildAction);
            value=sprintf('%sSourcePath = %s\n',value,h.SourcePath);
            value=sprintf('%sOutputPath = %s\n',value,h.OutputPath);
            value=sprintf('%sDerivedPath = %s\n',value,h.DerivedPath);
            value=sprintf('%sMakeInclude = %s\n',value,h.MakeInclude);
            value=sprintf('%sCompilerPath = %s\n',value,h.CompilerPath);
            value=sprintf('%sToolChainCompilerArgs = %s\n',value,h.ToolChainCompilerArgs);
            value=sprintf('%sCodeGenCompilerArgs = %s\n',value,h.CodeGenCompilerArgs);
            value=sprintf('%sLinkerPath = %s\n',value,h.LinkerPath);
            value=sprintf('%sToolChainLinkerArgs = %s\n',value,h.ToolChainLinkerArgs);
            value=sprintf('%sCodeGenLinkerArgs = %s\n',value,h.CodeGenLinkerArgs);

            feature=linkfoundation.xmakefile.XMakefileTemplate.OFF;
            if(h.PrebuildFeatureEnable),
                feature=linkfoundation.xmakefile.XMakefileTemplate.ON;
            end
            value=sprintf('%sPrebuild = %s\n',value,feature);
            value=sprintf('%sPrebuildPath = %s\n',value,h.PrebuildPath);
            value=sprintf('%sPrebuildArgs = %s\n',value,h.PrebuildArgs);

            feature=linkfoundation.xmakefile.XMakefileTemplate.OFF;
            if(h.PostbuildFeatureEnable),
                feature=linkfoundation.xmakefile.XMakefileTemplate.ON;
            end
            value=sprintf('%sPostbuild = %s\n',value,feature);
            value=sprintf('%sPostbuildPath = %s\n',value,h.PostbuildPath);
            value=sprintf('%sPostbuildArgs = %s\n',value,h.PostbuildArgs);

            feature=linkfoundation.xmakefile.XMakefileTemplate.OFF;
            if(h.ExecuteTargetFeatureEnable),
                feature=linkfoundation.xmakefile.XMakefileTemplate.ON;
            end
            value=sprintf('%sExececuteTarget = %s\n',value,feature);
            value=sprintf('%sExecutePath = %s\n',value,h.ExecutePath);

            value=sprintf('%sObjectExtension = %s\n',value,h.ObjectExtension);
            value=sprintf('%sTargetExtension = %s\n',value,h.TargetExtension);
            value=sprintf('%sTargetNamePrefix = %s\n',value,h.TargetNamePrefix);
            value=sprintf('%sTargetNamePostfix = %s\n',value,h.TargetNamePostfix);

            value=sprintf('%sCustom1 = %s\n',value,h.Custom1);
            value=sprintf('%sCustom2 = %s\n',value,h.Custom2);
            value=sprintf('%sCustom3 = %s\n',value,h.Custom3);
            value=sprintf('%sCustom4 = %s\n',value,h.Custom4);
            value=sprintf('%sCustom5 = %s\n',value,h.Custom5);

            value=sprintf('%sPrebuildLineOverride = %s\n',value,h.PrebuildLineOverride);
            value=sprintf('%sCompilerLineOverride = %s\n',value,h.CompilerLineOverride);
            value=sprintf('%sLinkerLineOverride = %s\n',value,h.LinkerLineOverride);
            value=sprintf('%sPostbuildLineOverride = %s\n',value,h.PostbuildLineOverride);
            value=sprintf('%sExecuteLineOverride = %s\n',value,h.ExecuteLineOverride);
            disp(value);
        end




        function value=isValid(h)
            value=false;
            if(isempty(h.Id))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_FORMAT_NAME').reportAsWarning;
                return;
            end
            if(isempty(h.Version))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_TEMPLATE_VERSION').reportAsWarning;
                return;
            end
            if(isempty(h.GeneratedTargetIdentifier))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_TARGET_IDENTIFIER').reportAsWarning;
                return;
            end
            if(isempty(h.OutputPathIdentifier))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_OUTPUT_PATH_IDENTIFIER').reportAsWarning;
                return;
            end
            if(isempty(h.DerivedPathIdentifier))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_DERIVED_PATH_IDENTIFIER').reportAsWarning;
                return;
            end
            if(isempty(h.CompilerToolChainIdentifier))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_COMPILER_TCCFG_IDENTIFIER').reportAsWarning;
                return;
            end
            if(isempty(h.CompilerCodeGenIdentifier))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_COMPILER_CODEGEN_IDENTIFIER').reportAsWarning;
                return;
            end
            if(isempty(h.LinkerCodeGenIdentifier))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_LINKER_CODEGEN_IDENTIFIER').reportAsWarning;
                return;
            end
            if(isempty(h.LinkerToolChainIdentifier))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid','[T]MW_XMK_LINKER_TCCFG_IDENTIFIER').reportAsWarning;
                return;
            end
            if(isempty(h.GeneratedFileExtension))
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_isValid_optional','[T]MW_XMK_GENERATED_FILE_EXTENSION').reportAsWarning;
            end
            value=true;
        end











        function value=instantiate(h,value)
            try
                if(1==nargin)
                    value=h.Content;
                end
                if(isempty(value))
                    value='';
                    return;
                end


                currentBuildAction=h.CurrentBuildActionIdentifier;
                buildAction=h.BuildActionIdentifier;
                executeAction=h.ExecuteActionIdentifier;


                targetIdentifier=h.GeneratedTargetIdentifier;



                outputPath=h.OutputPathIdentifier;





                sourcePath=h.SourcePathIdentifier;




                derivedPath=h.DerivedPathIdentifier;


                compilerCodeGen=h.CompilerCodeGenIdentifier;
                compilerToolChain=h.CompilerToolChainIdentifier;

                linkerCodeGen=h.LinkerCodeGenIdentifier;
                linkerToolChain=h.LinkerToolChainIdentifier;

                prebuildArgs=h.PrebuildArgsIdentifier;
                postbuildArgs=h.PostbuildArgsIdentifier;
                executeArgs=h.ExecuteArgsIdentifier;


                sourceFiles=h.SourceFilesIdentifier;
                headerFiles=h.HeaderFilesIdentifier;
                libraryFiles=h.LibraryFilesIdentifier;
                objectFiles=h.ObjectFilesIdentifier;
                skippedFiles=h.SkippedFilesIdentifier;


                compilerTool=h.CompilerToolIdentifier;
                linkerTool=h.LinkerToolIdentifier;
                prebuildTool=h.PrebuildToolIdentifier;
                postbuildTool=h.PostbuildToolIdentifier;
                executeTool=h.ExecuteToolIdentifier;










                format='\[\|T*MW_XMK_\w+={1}[^\|\]]*\|\]';
                newvalue=regexprep(value,format,'');
                value=removeMultipleLineFeeds(newvalue);



                pregroup='(?<pregroup>[^\|]+)?';
                preunit='(?<preunit>[^\|]+)?';
                default='(?<default>\[[^\|\]]+\])?';
                prefix=['\[\|',pregroup,'\|',preunit,'\|',default];

                modifier='(?<modifier>\[[^\|\]]+\])?';
                postunit='(?<postunit>[^\|]+)?';
                postgroup='(?<postgroup>[^\|]+)?';
                postfix=[modifier,'\|',postunit,'\|',postgroup,'\|\]'];

                replaceValue('T*MW_XMK_MODEL_NAME',h.ModelName);
                replaceValue('T*MW_XMK_TIMESTAMP',datestr(now));
                replaceFileList('T*MW_XMK_GENERATED_FILE_NAME',h.GeneratedFileName);






                replaceValue('T*MW_XMK_OUTPUT_PATH_REF',outputPath);
                replaceValue('T*MW_XMK_SOURCE_PATH_REF',sourcePath);
                replaceValue('T*MW_XMK_DERIVED_PATH_REF',derivedPath);


                replaceValue('T*MW_XMK_SOURCE_FILES_REF',sourceFiles);
                replaceValue('T*MW_XMK_HEADER_FILES_REF',headerFiles);
                replaceValue('T*MW_XMK_LIBRARY_FILES_REF',libraryFiles);
                replaceValue('T*MW_XMK_OBJECT_FILES_REF',objectFiles);
                replaceValue('T*MW_XMK_SKIPPED_FILES_REF',skippedFiles);


                replaceValue('T*MW_XMK_GENERATED_TARGET_REF',targetIdentifier);
                replaceValue('T*MW_XMK_ACTIVE_BUILD_ACTION_REF',currentBuildAction);
                replaceValue('T*MW_XMK_BUILD_ACTION_REF',buildAction);
                replaceValue('T*MW_XMK_EXECUTE_ACTION_REF',executeAction);


                replaceValue('T*MW_XMK_COMPILER_REF',compilerTool);
                replaceValue('T*MW_XMK_LINKER_REF',linkerTool);
                replaceValue('T*MW_XMK_PREBUILD_REF',prebuildTool);
                replaceValue('T*MW_XMK_POSTBUILD_REF',postbuildTool);
                replaceValue('T*MW_XMK_EXECUTE_REF',executeTool);


                replaceValue('T*MW_XMK_COMPILER_CODEGEN_REF',compilerCodeGen);
                replaceValue('T*MW_XMK_COMPILER_TCCFG_REF',compilerToolChain);
                replaceValue('T*MW_XMK_LINKER_CODEGEN_REF',linkerCodeGen);
                replaceValue('T*MW_XMK_LINKER_TCCFG_REF',linkerToolChain);
                replaceValue('T*MW_XMK_PREBUILD_ARGS_REF',prebuildArgs);
                replaceValue('T*MW_XMK_POSTBUILD_ARGS_REF',postbuildArgs);
                replaceValue('T*MW_XMK_EXECUTE_ARGS_REF',executeArgs);


                if(ispc())
                    platform=linkfoundation.xmakefile.XMakefileTemplate.WINDOWS;
                elseif(ismac())
                    platform=linkfoundation.xmakefile.XMakefileTemplate.MAC;
                elseif(isunix())
                    platform=linkfoundation.xmakefile.XMakefileTemplate.UNIX;
                else
                    platform=linkfoundation.xmakefile.XMakefileTemplate.UNKNOWN;
                end
                replaceValue('T*MW_XMK_HOST_ARCH',computer('arch'));
                replaceValue('T*MW_XMK_HOST_PLATFORM',platform);


                replaceValue('T*MW_XMK_WINDOWS_PLATFORM',linkfoundation.xmakefile.XMakefileTemplate.WINDOWS);
                replaceValue('T*MW_XMK_UNIX_PLATFORM',linkfoundation.xmakefile.XMakefileTemplate.UNIX);
                replaceValue('T*MW_XMK_MAC_PLATFORM',linkfoundation.xmakefile.XMakefileTemplate.MAC);
                replaceValue('T*MW_XMK_UNKNOWN_PLATFORM',linkfoundation.xmakefile.XMakefileTemplate.UNKNOWN);


                replaceValue('T*MW_XMK_WIN32_ARCH',linkfoundation.xmakefile.XMakefileTemplate.WIN32);
                replaceValue('T*MW_XMK_WIN64_ARCH',linkfoundation.xmakefile.XMakefileTemplate.WIN64);
                replaceValue('T*MW_XMK_GLNX86_ARCH',linkfoundation.xmakefile.XMakefileTemplate.GLNX86);
                replaceValue('T*MW_XMK_GLNXA64_ARCH',linkfoundation.xmakefile.XMakefileTemplate.GLNXA64);
                replaceValue('T*MW_XMK_MACI_ARCH',linkfoundation.xmakefile.XMakefileTemplate.MACI);
                replaceValue('T*MW_XMK_MACI64_ARCH',linkfoundation.xmakefile.XMakefileTemplate.MACI64);
                replaceValue('T*MW_XMK_UNKNOWN_ARCH',linkfoundation.xmakefile.XMakefileTemplate.UNKNOWN);


                replaceValue('T*MW_XMK_FEATURE_ON',linkfoundation.xmakefile.XMakefileTemplate.ON);
                replaceValue('T*MW_XMK_FEATURE_OFF',linkfoundation.xmakefile.XMakefileTemplate.OFF);

                replaceValue('T*MW_XMK_BUILD_CFG',h.BuildConfiguration);
                replaceValue('T*MW_XMK_TOOL_CHAIN_CFG',h.ToolChainConfiguration);
                replaceValue('T*MW_XMK_TOOL_CHAIN_CFG_VERSION',h.ToolChainConfigurationVersion);
                replaceValue('T*MW_XMK_TARGET_EXT',h.TargetExtension);
                replaceValue('T*MW_XMK_TARGET_NAME_PREFIX',h.TargetNamePrefix);
                replaceValue('T*MW_XMK_TARGET_NAME_POSTFIX',h.TargetNamePostfix);
                if(isempty(h.SourcePath))
                    h.SourcePath=pwd;
                end
                replacePathList('T*MW_XMK_MATLAB_ROOT',matlabroot);
                replacePathList('T*MW_XMK_SOURCE_PATH',h.SourcePath);
                replacePathList('T*MW_XMK_OUTPUT_PATH',h.OutputPath);
                replacePathList('T*MW_XMK_DERIVED_PATH',h.DerivedPath);
                replaceFileList('T*MW_XMK_INCLUDE_FILE',h.MakeInclude);
                replaceValue('T*MW_XMK_COMPILER_CODEGEN',h.CodeGenCompilerArgs);
                replaceValue('T*MW_XMK_COMPILER_TCCFG',h.ToolChainCompilerArgs);
                replaceFileList('T*MW_XMK_COMPILER_PATH',h.CompilerPath);
                replaceValue('T*MW_XMK_LINKER_CODEGEN',h.CodeGenLinkerArgs);
                replaceValue('T*MW_XMK_LINKER_TCCFG',h.ToolChainLinkerArgs);
                replaceFileList('T*MW_XMK_LINKER_PATH',h.LinkerPath);

                if(h.PrebuildFeatureEnable)
                    replaceValue('T*MW_XMK_FEATURE_PREBUILD',linkfoundation.xmakefile.XMakefileTemplate.ON);
                    replaceValue('T*MW_XMK_PREBUILD_ARGS',h.PrebuildArgs);
                    replaceFileList('T*MW_XMK_PREBUILD_TOOL_PATH',h.PrebuildPath);
                else
                    replaceValue('T*MW_XMK_FEATURE_PREBUILD',linkfoundation.xmakefile.XMakefileTemplate.OFF);
                end

                if(h.PostbuildFeatureEnable)
                    replaceValue('T*MW_XMK_FEATURE_POSTBUILD',linkfoundation.xmakefile.XMakefileTemplate.ON);
                    replaceValue('T*MW_XMK_POSTBUILD_ARGS',h.PostbuildArgs);
                    replaceFileList('T*MW_XMK_POSTBUILD_TOOL_PATH',h.PostbuildPath);
                else
                    replaceValue('T*MW_XMK_FEATURE_POSTBUILD',linkfoundation.xmakefile.XMakefileTemplate.OFF);
                end

                if(h.ExecuteTargetFeatureEnable)
                    replaceValue('T*MW_XMK_FEATURE_EXECUTE_TARGET',linkfoundation.xmakefile.XMakefileTemplate.ON);
                else
                    replaceValue('T*MW_XMK_FEATURE_EXECUTE_TARGET',linkfoundation.xmakefile.XMakefileTemplate.OFF);
                    replaceFileList('T*MW_XMK_EXECUTE_TOOL_PATH',h.ExecutePath);
                end
                replaceValue('T*MW_XMK_EXECUTE_ARGS',h.ExecuteArgs);

                replaceFileList('T*MW_XMK_SOURCE_FILES',h.SourceFiles);
                replaceFileList('T*MW_XMK_HEADER_FILES',h.HeaderFiles);
                replaceFileList('T*MW_XMK_LIBRARY_FILES',h.LibraryFiles);
                replaceFileList('T*MW_XMK_SKIPPED_FILES',h.SkippedFiles);
                replaceValue('T*MW_XMK_OBJ_EXT',h.ObjectExtension);


                replaceValue('T*MW_XMK_CUSTOM1',h.Custom1);
                replaceValue('T*MW_XMK_CUSTOM2',h.Custom2);
                replaceValue('T*MW_XMK_CUSTOM3',h.Custom3);
                replaceValue('T*MW_XMK_CUSTOM4',h.Custom4);
                replaceValue('T*MW_XMK_CUSTOM5',h.Custom5);


                replaceValue('T*MW_XMK_PREBUILD_LINE',h.PrebuildLineOverride);
                replaceValue('T*MW_XMK_COMPILER_LINE',h.CompilerLineOverride);
                replaceValue('T*MW_XMK_LINKER_LINE',h.LinkerLineOverride);
                replaceValue('T*MW_XMK_POSTBUILD_LINE',h.PostbuildLineOverride);
                replaceValue('T*MW_XMK_EXECUTE_LINE',h.ExecuteLineOverride);


                replaceDefaultValue();


                value=regexprep(value,[prefix,'T*MW_XMK_\w+',postfix],'');

            catch ex
                linkfoundation.xmakefile.raiseException('XMakefileTemplate','Instantiate','',ex,value);
            end








            function replaceDefaultValue()
                multiValue={};
                if(iscell(value))
                    multiValue=value;
                else
                    multiValue{1}=value;
                end
                for i=1:length(multiValue)
                    names=regexp(multiValue{i},[prefix,'(?(default)T*MW_XMK_\w+)',postfix],'names');
                    if(isempty(names))
                        continue;
                    end
                    for j=1:length(names)
                        defaultValue=regexprep(names(j).default,'^\[(?<value>[^\]]+)\]$','$<value>');
                        multiValue{i}=regexprep(multiValue{i},[prefix,'(?(default)T*MW_XMK_\w+)',postfix],['$<pregroup>$<preunit>',defaultValue,'$<postunit>$<postgroup>'],'once');
                    end
                end
                if(iscell(value))
                    value=multiValue;
                else
                    value=multiValue{1};
                end
            end








            function replaceValue(identifier,source)
                if(isempty(identifier)||isempty(source))
                    return;
                end
                multiValue={};
                if(iscell(value))
                    multiValue=value;
                else
                    multiValue{1}=value;
                end
                for i=1:length(multiValue)
                    names=regexp(multiValue{i},[prefix,identifier,postfix],'names');
                    if(isempty(names))
                        continue;
                    end
                    for j=1:length(names)
                        modifier=regexprep(names(j).modifier,'^\[(?<value>[^\]]+)\]$','$<value>');
                        switch(lower(modifier))
                        case 'u'
                            modifiedSource=upper(source);
                        case 'l'
                            modifiedSource=lower(source);
                        otherwise
                            modifiedSource=source;
                        end
                        multiValue{i}=regexprep(multiValue{i},...
                        [prefix,identifier,postfix],...
                        ['$<pregroup>$<preunit>',h.formatString(modifiedSource),'$<postunit>$<postgroup>'],'once');
                    end
                end
                if(iscell(value))
                    value=multiValue;
                else
                    value=multiValue{1};
                end
            end








            function replaceFileList(identifier,inFiles)
                if(isempty(identifier)||isempty(inFiles))
                    return;
                end
                multiValue={};
                if(iscell(value))
                    multiValue=value;
                else
                    multiValue{1}=value;
                end
                fileList={};
                if(iscell(inFiles))
                    fileList=inFiles;
                else
                    fileList{1}=inFiles;
                end
                for i=1:length(multiValue)
                    names=regexp(multiValue{i},[prefix,identifier,postfix],'names','warnings');
                    if(isempty(names))
                        continue;
                    end
                    files={size(names)};
                    for j=1:length(names)
                        files{j}='';
                        for k=1:length(fileList)
                            files{j}=[files{j}...
                            ,names(j).preunit...
                            ,h.formatFile(fileList{k},names(j).modifier)...
                            ,names(j).postunit];
                        end
                        files{j}=strtrim(files{j});
                    end
                    for l=1:length(names)
                        multiValue{i}=regexprep(multiValue{i},[prefix,identifier,postfix],['$<pregroup>',h.formatString(files{l}),'$<postgroup>'],'once','warnings');
                    end
                end
                if(iscell(value))
                    value=multiValue;
                else
                    value=multiValue{1};
                end
            end








            function replacePathList(identifier,inPaths)
                if(isempty(identifier)||isempty(inPaths))
                    return;
                end
                multiValue={};
                if(iscell(value))
                    multiValue=value;
                else
                    multiValue{1}=value;
                end
                pathList={};
                if(iscell(inPaths))
                    pathList=inPaths;
                else
                    pathList{1}=inPaths;
                end
                for i=1:length(multiValue)
                    names=regexp(multiValue{i},[prefix,identifier,postfix],'names');
                    if(isempty(names))
                        continue;
                    end
                    paths={size(names)};
                    for j=1:length(names)
                        paths{j}='';
                        for k=1:length(pathList)
                            paths{j}=[paths{j}...
                            ,names(j).preunit...
                            ,h.formatPath(pathList{k},names(j).modifier)...
                            ,names(j).postunit];
                        end
                        paths{j}=strtrim(paths{j});
                    end
                    for l=1:length(names)
                        multiValue{i}=regexprep(multiValue{i},[prefix,identifier,postfix],['$<pregroup>',h.formatString(paths{l}),'$<postgroup>'],'once');
                    end
                end
                if(iscell(value))
                    value=multiValue;
                else
                    value=multiValue{1};
                end
            end






            function text=removeMultipleLineFeeds(newvalue)
                if strcmp(value,newvalue)
                    text=value;
                else
                    carriageReturn=char(10);
                    lineFeed=char(13);
                    pattern1=[lineFeed,carriageReturn];
                    text=regexprep(newvalue,...
                    ['(',pattern1,'){3,50}'],...
                    repmat(pattern1,1,2));
                    pattern2=carriageReturn;
                    text=regexprep(text,...
                    ['(',pattern2,'){3,50}'],...
                    repmat(pattern2,1,2));
                end
            end

        end




        function reset(h)
            h.ModelName='';
            h.GeneratedFileName='';
            h.BuildConfiguration='';
            h.ToolChainConfiguration='';
            h.ToolChainConfigurationVersion='';
            h.BuildAction=linkfoundation.xmakefile.XMakefileTemplate.TARGET_NONE;
            h.SourcePath='';
            h.OutputPath='';
            h.DerivedPath='';
            h.MakeInclude='';
            h.ToolChainCompilerArgs='';
            h.CodeGenCompilerArgs='';
            h.CompilerPath='';
            h.ToolChainLinkerArgs='';
            h.CodeGenLinkerArgs='';
            h.LinkerPath='';
            h.PrebuildFeatureEnable=false;
            h.PrebuildArgs='';
            h.PrebuildPath='';
            h.PostbuildFeatureEnable=false;
            h.PostbuildArgs='';
            h.PostbuildPath='';
            h.ExecuteTargetFeatureEnable=false;
            h.ExecutePath='';
            h.ExecuteArgs='';
            h.SourceFiles={};
            h.HeaderFiles={};
            h.LibraryFiles={};
            h.SkippedFiles={};
            h.ObjectExtension='';
            h.TargetExtension='';
            h.TargetNamePrefix='';
            h.TargetNamePostfix='';
            h.Custom1='';
            h.Custom2='';
            h.Custom3='';
            h.Custom4='';
            h.Custom5='';
            h.PrebuildLineOverride='';
            h.CompilerLineOverride='';
            h.LinkerLineOverride='';
            h.PostbuildLineOverride='';
            h.ExecuteLineOverride='';
        end
    end

    methods(Access='private')





        function value=formatString(~,inValue)
            value=strrep(inValue,'\','\\');
            value=strrep(value,'$','\$');
        end


        function value=formatPath(~,inPath,modifier)
            value='';

            if(isempty(inPath))
                return;
            end
            if(isa(inPath,'linkfoundation.util.Location'))
                inPath=inPath.Path;
            end
            value=inPath;




            if(regexp(inPath,'^\$\(\w+\)$'))
                return;
            end




            if(regexp(inPath,'^\%\w+\%$'))
                return;
            end

            location=linkfoundation.util.Location(value);
            value=location.Path;
            if(~isempty(modifier))
                for index=1:length(modifier)
                    location=linkfoundation.util.Location(value);
                    switch lower(modifier(index))
                    case 'r'
                        value=location.relativePathTo(pwd);
                    case 's'
                        value=location.ShortPath;
                    case 'e'
                        value=location.LongPath;
                    case 'd'
                        value=location.Drive;
                    end
                end
            end
        end


        function value=formatFile(~,inFile,modifier)
            value='';

            if(isempty(inFile))
                return;
            end
            if(isa(inFile,'linkfoundation.util.File'))
                inFile=inFile.FullPathName;
            end
            value=inFile;




            if(regexp(inFile,'^\$\(\w+\)$'))
                return;
            end




            if(regexp(inFile,'^\%\w+\%$'))
                return;
            end
            if(~isempty(modifier))
                modifier=regexprep(modifier,'^\[(?<value>[^\]]+)\]$','$<value>');
                for index=1:length(modifier)
                    file=linkfoundation.util.File(value);
                    switch lower(modifier(index))
                    case 'r'
                        value=file.relativePathTo(pwd);






                        if(file.isUNCPath()&&ischar(inFile)&&~isempty(regexp(inFile,'\\\\\\\\','once')))
                            value=strrep(value,'\','\\');
                        end
                    case 'f'
                        value=file.FileName;
                    case 'p'
                        value=file.Path;
                    case 's'
                        value=file.ShortFullPathName;
                    case 'e'
                        value=file.LongFullPathName;
                    case 'x'
                        value=file.Extension;
                    case 'd'
                        value=file.Drive;
                    case 'c'
                        currentLocation=linkfoundation.util.Location(pwd);

                        file=linkfoundation.util.File(file.LongFullPathName);
                        destination=linkfoundation.util.File(fullfile(pwd,file.FileName));
                        if(currentLocation.isFolderWritable()&&file.exists()&&destination~=file)
                            copyfile(file.FullPathName,destination.FullPathName,'f');
                        end
                        value=destination.FullPathName;
                    end
                end
            end
        end




        function value=PlaceHolderValue(h,Id)
            if(h.exists())
                value=regexp(h.Content,['\[\|',Id,'=([^\|\]]*)\|\]'],'tokens');
            end
            if(isempty(value))
                value={''};
            end
        end
    end

    methods





        function value=get.Id(h)
            value=h.PlaceHolderValue('T*MW_XMK_FORMAT_NAME');
            value=char(value{1});
        end





        function value=get.Version(h)
            value=h.PlaceHolderValue('T*MW_XMK_TEMPLATE_VERSION');
            if(isempty(value))
                linkfoundation.xmakefile.raiseException('XMakefileTemplate','Version','',[],h.FullPathName);
            end
            value=char(value{1});
        end




        function value=get.GeneratedFileExtension(h)
            value=h.PlaceHolderValue('T*MW_XMK_GENERATED_FILE_EXTENSION');
            value=char(value{1});
        end





        function value=get.GeneratedTargetIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_GENERATED_TARGET_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.OutputPathIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_OUTPUT_PATH_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.SourcePathIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_SOURCE_PATH_IDENTIFIER');
            if(isempty(value))
                if(isempty(h.SourcePath))
                    value={pwd};
                else
                    value={h.SourcePath};
                end
            end
            value=char(value{1});
        end





        function value=get.DerivedPathIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_DERIVED_PATH_IDENTIFIER');
            value=char(value{1});
        end






        function value=get.CompilerCodeGenIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_COMPILER_CODEGEN_IDENTIFIER');
            value=char(value{1});
        end






        function value=get.CompilerToolChainIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_COMPILER_TCCFG_IDENTIFIER');
            value=char(value{1});
        end






        function value=get.LinkerCodeGenIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_LINKER_CODEGEN_IDENTIFIER');
            value=char(value{1});
        end






        function value=get.LinkerToolChainIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_LINKER_TCCFG_IDENTIFIER');
            value=char(value{1});
        end






        function value=get.PrebuildArgsIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_PREBUILD_ARGS_IDENTIFIER');
            value=char(value{1});
        end






        function value=get.PostbuildArgsIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_POSTBUILD_ARGS_IDENTIFIER');
            value=char(value{1});
        end






        function value=get.ExecuteArgsIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_EXECUTE_ARGS_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.BuildActionIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_BUILD_ACTION_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.ExecuteActionIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_EXECUTE_ACTION_IDENTIFIER');
            value=char(value{1});
        end




        function value=get.CurrentBuildActionIdentifier(h)
            if(strcmp(linkfoundation.xmakefile.XMakefileTemplate.TARGET_BUILD,h.BuildAction))
                placeHolder='T*MW_XMK_BUILD_ACTION_IDENTIFIER';
            elseif(strcmp(linkfoundation.xmakefile.XMakefileTemplate.TARGET_EXECUTE,h.BuildAction))
                placeHolder='T*MW_XMK_EXECUTE_ACTION_IDENTIFIER';
            else



                placeHolder='T*MW_XMK_DEFAULT_ACTION_IDENTIFIER';
            end
            value=h.PlaceHolderValue(placeHolder);
            if(isempty(value))
                value={h.BuildAction};
            end
            value=char(value{1});
        end





        function value=get.SourceFilesIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_SOURCE_FILES_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.HeaderFilesIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_HEADER_FILES_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.LibraryFilesIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_LIBRARY_FILES_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.ObjectFilesIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_OBJECT_FILES_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.SkippedFilesIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_SKIPPED_FILES_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.CompilerToolIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_COMPILER_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.LinkerToolIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_LINKER_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.PrebuildToolIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_PREBUILD_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.PostbuildToolIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_POSTBUILD_IDENTIFIER');
            value=char(value{1});
        end





        function value=get.ExecuteToolIdentifier(h)
            value=h.PlaceHolderValue('T*MW_XMK_EXECUTE_IDENTIFIER');
            value=char(value{1});
        end




        function value=get.Content(h)
            value='';
            if(h.exists())
                if((~ischar(h.FileData)||isempty(h.FileData))&&h.exists)


                    h.FileData=fileread(h.FullPathName);
                end
                value=h.FileData;
            end
        end
    end

    methods(Static=true,Access='public')









        function templates=getTemplates(reload)
            persistent repository;
            if(0==nargin)
                reload=false;
            end
            if(~isa(repository,'containers.Map')||reload)
                repository=containers.Map;
                linkfoundation.xmakefile.XMakefileTemplate.loadTemplates(repository);
                activeTemplate=linkfoundation.xmakefile.XMakefileTemplate.getActiveTemplate();
                if((isempty(activeTemplate)||~linkfoundation.xmakefile.XMakefileTemplate.isTemplate(activeTemplate))&&~isempty(repository))
                    v=repository.values;
                    linkfoundation.xmakefile.XMakefileTemplate.setActiveTemplate(v{1}.Id);
                end
            end
            templates=repository;
        end




        function reload()
            linkfoundation.xmakefile.XMakefileTemplate.getTemplates(true);
        end




        function template=getTemplate(id)
            template=[];
            if(isempty(id))
                return;
            end
            key=linkfoundation.xmakefile.XMakefileTemplate.mapKey(id);
            templates=linkfoundation.xmakefile.XMakefileTemplate.getTemplates();
            if(templates.isKey(key))
                template=templates(key);
            else
                MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_getTemplate',id).reportAsWarning;
            end
        end




        function active=setActiveTemplate(id)
            active=false;
            if(~isempty(id))
                templates=linkfoundation.xmakefile.XMakefileTemplate.getTemplates();
                key=linkfoundation.xmakefile.XMakefileTemplate.mapKey(id);
                if(templates.isKey(key))
                    activeTemplateId=templates(key).Id;
                    linkfoundation.xmakefile.XMakefilePreferences.setActiveTemplate(activeTemplateId);
                    active=true;
                else
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_setActiveTemplate',id).reportAsWarning;
                end
            end
        end




        function template=getActiveTemplate()
            template=linkfoundation.xmakefile.XMakefilePreferences.getActiveTemplate();
            if(isempty(template)||~linkfoundation.xmakefile.XMakefileTemplate.isTemplate(template))
                repository=linkfoundation.xmakefile.XMakefileTemplate.getTemplates();
                if(~isempty(repository))
                    v=repository.values;
                    linkfoundation.xmakefile.XMakefileTemplate.setActiveTemplate(v{1}.Id);
                    template=linkfoundation.xmakefile.XMakefilePreferences.getActiveTemplate();
                end
            end
        end




        function displayTemplates()
            templates=linkfoundation.xmakefile.XMakefileTemplate.getTemplates();
            if(isempty(templates))
                fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefileTemplate_displayTemplates_empty'));
                return;
            end
            values=templates.values;
            fprintf('%s\n',DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_XMakefileTemplate_displayTemplates_header'));
            for index=1:length(values)
                template=values{index};
                systemStr=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_false');
                if(template.IsSystemDefined)
                    systemStr=DAStudio.message('ERRORHANDLER:xmakefile:xmk_txt_true');
                end
                fprintf('%s -- %s -- %s\n',template.Id,systemStr,template.FullPathName);
            end
        end





        function test=isTemplate(id)
            test=false;
            templates=linkfoundation.xmakefile.XMakefileTemplate.getTemplates();
            key=linkfoundation.xmakefile.XMakefileTemplate.mapKey(id);
            if(templates.isKey(key))
                test=true;
            end
        end
    end

    methods(Static=true,Access='private')






        function key=mapKey(value)
            if(~ischar(value))
                key=lower(char(value));
            else
                key=lower(value);
            end
        end





        function loadTemplates(map)
            warnstate=warning('off','MATLAB:UIW_DOSUNC');
            templateDir=linkfoundation.xmakefile.XMakefilePreferences.getDefaultTemplateLocation();
            linkfoundation.xmakefile.XMakefileTemplate.loadTemplatesFromLocation(map,templateDir);
            templateDir=linkfoundation.xmakefile.XMakefilePreferences.getUserTemplateLocation();
            linkfoundation.xmakefile.XMakefileTemplate.loadTemplatesFromLocation(map,templateDir);
            warning(warnstate);
        end





        function loadTemplatesFromLocation(map,location)
            files=location.files(['*',linkfoundation.xmakefile.XMakefileTemplate.MakefileTemplateExtension]);
            for index=1:length(files)
                template=linkfoundation.xmakefile.XMakefileTemplate(files{index});
                if(~template.isValid())
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_loadTemplatesFromLocation_isValid',template.FullPathName).reportAsWarning;
                    continue;
                end
                key=linkfoundation.xmakefile.XMakefileTemplate.mapKey(template.Id);
                if(isempty(key))
                    continue;
                end
                if(map.isKey(key))
                    existing=map(key);
                    MSLDiagnostic('ERRORHANDLER:xmakefile:xmk_warning_XMakefileTemplate_loadTemplatesFromLocation',char(template.Id),template.FullPathName,existing.FullPathName).reportAsWarning;
                    continue;
                end
                map(key)=template;
            end
        end
    end
end
