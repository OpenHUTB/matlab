function updateLibraryConfigSetSettings(obj,hMdl)


    if~obj.importAsLibrary
        set_param(hMdl,'SolverType','Fixed-step');
    end

    set_param(hMdl,'SimTargetLang',obj.qualifiedSettings.CustomCode.Language);


    if obj.qualifiedSettings.CustomCode.GlobalVariableInterface
        set_param(hMdl,'CustomCodeGlobalsAsFunctionIO','on');
    else
        set_param(hMdl,'CustomCodeGlobalsAsFunctionIO','off');
    end


    internal.CodeImporter.setFunctionArrayLayout(obj,hMdl);


    internal.CodeImporter.setFunctionDeterministicBehavior(obj,hMdl);


    if obj.isSLUnitTest

        set_param(hMdl,'CustomCodeUndefinedFunction','DoNotDetect');
    else
        set_param(hMdl,'CustomCodeUndefinedFunction',char(obj.Options.UndefinedFunctionHandling));
    end


    if obj.isSLUnitTest

        allSrcs=obj.SbxCustomCode.SourceFiles;
    else


        allSrcs=obj.qualifiedSettings.CustomCode.SourceFiles;
    end

    allSrcsRelative=internal.CodeImporter.Tools.convertToRelativePath(allSrcs,obj.qualifiedSettings.OutputFolder);
    allSrcsStr=sprintf('%s\n',allSrcsRelative{:});
    set_param(hMdl,'SimUserSources',allSrcsStr);


    if obj.isSLUnitTest








        if obj.SandboxSettings.generateInterfaceHeader()
            includeFiles=obj.InterfaceHeaderFileName;
        else
            [~,hFileName,hFileExt]=fileparts(obj.SbxCustomCode.InterfaceHeaders);
            includeFiles=hFileName+hFileExt;
        end
    else




        includeFiles=obj.qualifiedSettings.CustomCode.InterfaceHeaders(obj.qualifiedSettings.CustomCode.InterfaceHeaders~="");


        for idx=1:length(includeFiles)
            includeFiles{idx}=strip(includeFiles{idx},'"');
        end
    end

    allIncludeStr=sprintf('#include "%s"\n',includeFiles{:});
    set_param(hMdl,'SimCustomHeaderCode',allIncludeStr);


    if obj.isSLUnitTest

        allIncludeRelativePath=internal.CodeImporter.Tools.convertToRelativePath(fullfile(obj.SandboxPath,'include'),obj.qualifiedSettings.OutputFolder);



        if obj.SandboxSettings.Mode==internal.CodeImporter.SandboxTypeEnum.UseOriginalCode&&...
            ~obj.SandboxSettings.CopySourceFiles
            allIncludeRelativePath=unique([allIncludeRelativePath,...
            internal.CodeImporter.Tools.convertToRelativePath(obj.qualifiedSettings.CustomCode.IncludePaths,obj.qualifiedSettings.OutputFolder)]);
        end
    else

        allIncludeRelativePath=internal.CodeImporter.Tools.convertToRelativePath(obj.qualifiedSettings.CustomCode.IncludePaths,obj.qualifiedSettings.OutputFolder);
    end
    allIncludePathStr=sprintf('%s\n',allIncludeRelativePath{:});
    set_param(hMdl,'SimUserIncludeDirs',allIncludePathStr);

    if~isempty(obj.qualifiedSettings.CustomCode.Libraries)
        allLibsRelativePath=internal.CodeImporter.Tools.convertToRelativePath(obj.qualifiedSettings.CustomCode.Libraries,obj.qualifiedSettings.OutputFolder);
        allLibsPathStr=sprintf('%s\n',allLibsRelativePath{:});
        set_param(hMdl,'SimUserLibraries',allLibsPathStr);
    end

    allDefines=sprintf('%s\n',obj.qualifiedSettings.CustomCode.Defines{:});
    set_param(hMdl,'SimUserDefines',allDefines);

    allCompilerFlags=sprintf('%s ',obj.qualifiedSettings.CustomCode.CompilerFlags{:});
    set_param(hMdl,'SimCustomCompilerFlags',allCompilerFlags);

    allLinkerFlags=sprintf('%s ',obj.qualifiedSettings.CustomCode.LinkerFlags{:});
    set_param(hMdl,'SimCustomLinkerFlags',allLinkerFlags);





    set_param(hMdl,'SimAnalyzeCustomCode','on');


    set_param(hMdl,'RTWUseSimCustomCode','on');


    set_param(hMdl,'SimDebugExecutionForCustomCode','off');
    if obj.Options.SimulateInSeparateProcess
        set_param(hMdl,'SimDebugExecutionForCustomCode','on');
    end
end
