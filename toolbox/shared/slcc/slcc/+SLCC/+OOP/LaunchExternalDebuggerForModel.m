function LaunchExternalDebuggerForModel(modelH,forceInProcessDebugging)
    if nargin<2
        forceInProcessDebugging=false;
    end

    if isempty(modelH)||~is_simulink_handle(modelH)
        return;
    end


    modelName=get_param(modelH,'Name');


    cgxeprivate('compilerman','reset_compiler_info');
    [isCCompilerSupported,cCompiler]=isSupportedDebugger(false);
    [isCPPCompilerSupported,cppCompiler]=isSupportedDebugger(true);

    if forceInProcessDebugging

        try
            breakpoints=target.internal.Breakpoint.empty();
            customCodeSettings=CGXE.CustomCode.CustomCodeSettings.createFromModel(modelName);

            isCpp=customCodeSettings.isCpp;
            if isVSCodeDebugging(isCpp,cCompiler,cppCompiler)
                error('VSCode Debugging is not supported for MEX Debugging');
            end
            checkForUnsupportedCompiler(isCpp,isCCompilerSupported,cCompiler,isCPPCompilerSupported,cppCompiler);
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().createInProcessDebugger(breakpoints,{},modelName,customCodeSettings.isCpp);
        catch ME
            exception=MSLException(message('Simulink:CustomCode:ExternalDebuggerLaunchFailure'));
            exception=addCause(exception,ME);
            SLCC.Utils.displayOnDiagnosticViewer(modelName,'error',exception);
        end
        return;
    end

    if strcmpi(get_param(modelH,'SimulationStatus'),'stopped')
        try

            set_param(modelH,'SimulationCommand','Update');
        catch ME
            exception=MSLException(ME);
            throw(exception);
        end
    end


    libraryCCDeps=slcc('getCachedCustomCodeDependencies',modelH);
    isInProcessDebuggerRequired=false;
    isOutOfProcessDebuggerRequired=false;
    srcFilesForInProcessDebugger=[];
    isUseCppCompilerForInProcessDebugger=false;

    SLM3I.ScopedStudioBlocker(getString(message('Simulink:CustomCode:ExternalDebuggerLaunchingStatusTip')));
    inProcessChecksums=[];
    for i=1:numel(libraryCCDeps)
        checkSum=libraryCCDeps(i).SettingsChecksum;
        assert(~isempty(checkSum),'Empty custom code checksum in cached custom code dependencies!');
        slcc('setIsExternalDebuggerLaunched',checkSum);
        moduleBreakpointsInfo=slcc('getOOPDebugInfos',checkSum);
        if~libraryCCDeps(i).IsOutOfProcessExecution
            if~isempty(libraryCCDeps(i).CustomCodeLibPath)
                isInProcessDebuggerRequired=true;
                inProcessChecksums=[inProcessChecksums,{checkSum}];%#ok
                if libraryCCDeps(i).IsSimLangCpp
                    isUseCppCompilerForInProcessDebugger=true;
                end
                srcFilesForInProcessDebugger=[{moduleBreakpointsInfo.FileFullPath},srcFilesForInProcessDebugger];%#ok
            end
        else
            expectedExeFullPath=SLCC.OOP.getCustomCodeExeExpectedFullPath(checkSum,libraryCCDeps(i).FullChecksum);
            if exist(expectedExeFullPath,'file')==2
                isOutOfProcessDebuggerRequired=true;

                checkForUnsupportedCompiler(libraryCCDeps(i).IsSimLangCpp,isCCompilerSupported,cCompiler,isCPPCompilerSupported,cppCompiler);
                if ismac
                    exception=MSLException(message('Simulink:CustomCode:ExternalDebuggerUnsupportedOnMacWithOOP'));
                    throw(exception);
                end
                srcFilesForOutOfProcessDebugger=CGXE.Utils.orderedUniquePaths({moduleBreakpointsInfo.FileFullPath});
                LaunchExternalDebuggerWithProcess(true,[],checkSum,srcFilesForOutOfProcessDebugger,modelName,libraryCCDeps(i).IsSimLangCpp);
            end
        end
    end

    if~isInProcessDebuggerRequired&&~isOutOfProcessDebuggerRequired
        parseCCLink=sprintf('<a href="matlab:SLCC.Utils.OpenConfigureSetAndHighlightParseCC(''%s'')">%s</a>',...
        modelName,configset.internal.getMessage('simParseCustomCodeName'));
        exception=MSLException(message('Simulink:CustomCode:ExternalDebuggerNoCustomCode',modelName,parseCCLink));
        if strcmp(get_param(modelName,'SimDebugExecutionForCustomCode'),'on')
            parseCCLink=sprintf('<a href="matlab:SLCC.Utils.OpenConfigureSetAndHighlightOOP(''%s'')">%s</a>',...
            modelName,configset.internal.getMessage('simDebugExecutionForCustomCodeName'));
            cause=MException(message('Simulink:CustomCode:ExternalDebuggerNotLaunchForOOP',parseCCLink));
            exception=addCause(exception,cause);
        end
        throw(exception);
    end

    if isInProcessDebuggerRequired



        assert(~isempty(inProcessChecksums));
        skipLaunchingDebugger=warnForInProcessVSCodeDebugging(modelName,...
        isUseCppCompilerForInProcessDebugger,...
        cCompiler,cppCompiler,inProcessChecksums);

        if~skipLaunchingDebugger

            checkForUnsupportedCompiler(isUseCppCompilerForInProcessDebugger,isCCompilerSupported,cCompiler,isCPPCompilerSupported,cppCompiler);
            srcFilesForInProcessDebugger=CGXE.Utils.orderedUniquePaths(srcFilesForInProcessDebugger);
            LaunchExternalDebuggerWithProcess(false,[],checkSum,srcFilesForInProcessDebugger,modelName,isUseCppCompilerForInProcessDebugger);
        end
    end

end

function skipLaunchingDebugger=warnForInProcessVSCodeDebugging(modelName,isCpp,cCompiler,cppCompiler,inProcessChecksums)
    skipLaunchingDebugger=false;

    if isVSCodeDebugging(isCpp,cCompiler,cppCompiler)
        skipLaunchingDebugger=true;













        exception=MSLException(message('Simulink:CustomCode:ExternalDebuggerDebuggingVSCodeNotSupportedWinInProcess'));
        for i=1:length(inProcessChecksums)
            modelH=slcc('getModelHandleFromSettingsChecksum',inProcessChecksums{i});
            if modelH==-1
                continue;
            end
            ccModelName=get_param(modelH,'Name');
            m=message('Simulink:CustomCode:ExternalDebuggerVSCodeNotSupportedInProcess_FixIt',...
            ccModelName);
            exception.addSuggestion(m.getString,...
            ['SLCC.Utils.OpenConfigureSetAndHighlightOOP(''',ccModelName,''')'],...
            'VSCodeDebuggerInProcessFixItId');
        end
        SLCC.Utils.displayOnDiagnosticViewer(modelName,'warning',exception);
    end
end

function isVSCode=isVSCodeDebugging(isCpp,cCompiler,cppCompiler)


    spkgManager=targetframework.internal.utilities.supportpackage.SupportPackageManager();
    isPackageInstalled=spkgManager.isInstalledAndEnabled('VSCodeDebugTool');
    if ispc
        isMinGWSelected=false;
        compiler=cCompiler;
        if isCpp
            compiler=cppCompiler;
        end

        if ismember(compiler,cgxeprivate('supportedPCCompilers','mingw'))
            isMinGWSelected=true;
        end


        isVSCode=isPackageInstalled&&isMinGWSelected;
    else
        isVSCode=isPackageInstalled;
    end
end

function LaunchExternalDebuggerWithProcess(isOOP,breakpointsInfo,settingChecksum,srcFiles,modelName,isCpp)

    breakpoints=target.internal.Breakpoint.empty();


    if strcmp(getenv('DebugSILWithMSVCTesting'),'1')||isunix
        breakpointsInfo=slcc('getOOPDebugInfos',settingChecksum);
    end

    if~isempty(breakpointsInfo)
        for idx=1:numel(breakpointsInfo)
            breakpoints(idx)=target.internal.create('Breakpoint',...
            'File',breakpointsInfo(idx).FileFullPath,...
            'Function',breakpointsInfo(idx).FunctionName);
        end
    end

    try

        if isOOP
            exePID=slcc('getExePID',settingChecksum);
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().createSLCCOOPSILDebugger(exePID,breakpoints,srcFiles,modelName,isCpp);
        else
            SLCC.OOP.slccOOPExternalDebuggerInfo.getInstance().createInProcessDebugger(breakpoints,srcFiles,modelName,isCpp);
        end
    catch ME
        exception=MSLException(message('Simulink:CustomCode:ExternalDebuggerLaunchFailure'));
        makeException=addCause(exception,ME);
        throw(makeException);
    end

end

function[isDebuggerSupported,compiler]=isSupportedDebugger(isCpp)
    compilerInfo=cgxeprivate('compilerman','get_compiler_info',isCpp);
    compiler=compilerInfo.compilerName;

    switch(compiler)
    case cgxeprivate('supportedPCCompilers','microsoft')
        isDebuggerSupported=true;
    case 'lcc'
        isDebuggerSupported=false;
    case cgxeprivate('supportedPCCompilers','mingw')
        isDebuggerSupported=true;
    case{'gcc','g++'}
        isDebuggerSupported=~ismac;
    case{'clang','clang++'}
        isDebuggerSupported=ismac;
    otherwise
        isDebuggerSupported=false;
    end

end

function checkForUnsupportedCompiler(isCpp,isCCompilerSupported,cCompiler,isCPPCompilerSupported,cppCompiler)
    if isCpp
        compiler=cppCompiler;
    else
        compiler=cCompiler;
    end

    if ismember(compiler,cgxeprivate('supportedPCCompilers','mingw'))
        spkgManager=targetframework.internal.utilities.supportpackage.SupportPackageManager();

        [status,details]=spkgManager.getInstallationStatus('VSCodeDebugTool');
        if status==targetframework.internal.utilities.supportpackage.InstallationStatus.NotInstalled




            callback=sprintf('matlab.internal.addons.launchers.showExplorer(''tripwire_customcodedebugging_vscodedebug'', ''identifier'', ''%s'')',details.BaseCode);

            exception=MSLException(message('Simulink:CustomCode:ExternalDebuggerDebuggingWithMinGW',details.PublishedName));
            exception.addSuggestion(message('targetframework:Utilities:InstallSupportPackage',details.PublishedName).getString(),callback,'tripwire_customcodedebugging_vscodedebug');
            exception.throw();
        end




    end

    if(~isCpp&&~isCCompilerSupported)||(isCpp&&~isCPPCompilerSupported)

        exception=MSLException(message('Simulink:CustomCode:ExternalDebuggerUnsupported',compiler));
        throw(exception);
    end
end