function buildArgs=createBuildArgs(mdl,modelCodegenFolder,varargin)




    activeConfigSet=getActiveConfigSet(mdl);


    p=inputParser();
    p.addOptional('BuildSpec','StandaloneCoderTarget',@coder.build.internal.isBuildSpec);
    p.addParameter('SlbDefaultCompInfo',[]);
    p.addParameter('SlbModelCompInfo',[]);
    p.addParameter('SlbXilCompInfo',[]);
    p.addParameter('SlbAutosarTwoPass',coder.internal.AutosarTwoPassBuild.None);
    p.addParameter('TopModelSilOrPilBuild',false,@islogical);
    p.addParameter('GenerateCodeOnly',strcmp(get_param(mdl,'GenCodeOnly'),'on'));
    p.addParameter('TopModelXILSim',false,@islogical);
    p.addParameter('InstrumentationSettingsModel',mdl,@ischar);
    p.addParameter('TopModelIsSilMode',false,@islogical);
    p.addParameter('SILModelReferences',[]);
    p.addParameter('PILModelReferences',[]);
    p.addParameter('SILModelReferencesTopModel',[]);
    p.addParameter('PILModelReferencesTopModel',[]);
    p.addParameter('StoredChecksum',[]);
    p.addParameter('StoredParameterChecksum',[]);
    p.addParameter('StoredTFLChecksum',[]);
    p.addParameter('OkayToPushNags',false);
    p.addParameter('CalledFromInsideSimulink',false);
    p.addParameter('IsExtModeOneClickSim',false);
    p.addParameter('IsExtModeXCP',...
    coder.internal.xcp.isXCPTarget(activeConfigSet),...
    @islogical);
    p.addParameter('OnlyCheckConfigsetMismatch',false);
    p.addParameter('UpdateDiagramOnly',false);
    p.addParameter('ForceTopModelBuild',false,@(x)(isscalar(x)&&(islogical(x)||x==0||x==1)));
    p.addParameter('OpenBuildStatusAutomatically',false);
    p.addParameter('LaunchCodeGenerationReport',true,@islogical);
    p.addParameter('HardwareBuildFolders',false);
    p.addParameter('UpdateThisModelReferenceTarget','',...
    @loc_validateUpdateThisModelReferenceTarget);
    p.addParameter('UpdateTopModelReferenceTarget',false);
    p.addParameter('ModelReferenceTargetType','SIM');
    p.addParameter('CmdlSimInpInfo',0,@isnumeric);
    if slfeature('ConfigSetActivator')>0
        p.addParameter('ConfigSet',[],@(x)(isa(x,'Simulink.ConfigSet')));
    end
    p.addParameter('SILDebugging',...
    loc_getDefaultSILDebugging(mdl),@islogical);
    p.addParameter('CodeCoverageSettings',...
    [],...
    @(x)(isa(x,'coder.coverage.CodeCoverageSettings')||isempty(x)));
    p.addParameter('TopModelAccelWithTimeProfiling',false,@islogical);
    p.addParameter('TopModelAccelWithStackProfiling',false,@islogical);
    p.addParameter('CodeExecutionProfilingTop',...
    loc_getDefaultCodeExecutionProfiling(mdl),@islogical);
    p.addParameter('CodeStackProfilingTop',...
    loc_getDefaultCodeStackProfiling(mdl),@islogical);
    p.addParameter('CodeProfilingWCETAnalysis',...
    loc_getDefaultCodeProfilingWCETAnalysis(mdl),@islogical);
    p.addParameter('ObfuscateCode',false);
    p.addParameter('SubSystemBuild',false,@(x)(isscalar(x)&&(islogical(x)||isnumeric(x))));
    p.addParameter('IsLibraryContextCodeGen',false,@islogical);
    p.addParameter('ParallelBuildContext',[]);
    p.addParameter('IncludeModelReferenceSimulationTargets',false,@(x)(isscalar(x)&&(islogical(x)||isnumeric(x))));
    p.addParameter('IsXILSubsystemHiddenModelBuild',false,@islogical);
    p.parse(varargin{:});


    [lBuildSpec,...
    lModelReferenceTargetType,...
    lTopModelStandalone,...
    lUpdateTopModelReferenceTarget,...
    lIsSimulationBuild]=coder.build.internal.getBuildSpecContext(p,mdl);

    loc_check_generateCodeCodeOnly(p,lBuildSpec);

    loc_check_IncludeModelReferenceSimulationTargets(lBuildSpec,...
    p.Results.IncludeModelReferenceSimulationTargets);

    lModelReferenceRTWTargetOnly=...
    any(strcmp(lBuildSpec,{'ModelReferenceRTWTargetOnly','ModelReferenceCoderTargetOnly'}));

    lProtectedModelReferenceTarget=isequal(lBuildSpec,'ModelReferenceProtectedSimTarget');



    if lProtectedModelReferenceTarget&&strcmp(get_param(mdl,'EnforceDataConsistency'),'off')
        throw(MSLException(...
        message('Simulink:modelReference:DataConsistencyOffNotSupportedWithProtectedModel',mdl)));
    end

    lGenerateMakefile=strcmp(get_param(mdl,'GenerateMakefile'),'on');


    lFirstModel='';
    lCodeCoverageSpec=[];





    if strcmp(get_param(mdl,'EnableParallelModelReferenceBuilds'),'on')



        [~,maxArrSz]=computer();
        if maxArrSz>2^31

            lCmdlSimInpInfo=uint8(zeros(1,8));
        else
            lCmdlSimInpInfo=uint8(zeros(1,4));
        end
    else
        lCmdlSimInpInfo=p.Results.CmdlSimInpInfo;
    end

    lIsExtModeOneClickSim=p.Results.IsExtModeOneClickSim;
    lUseChecksum=~isequal(p.Results.StoredChecksum,[]);
    lCodeExecutionProfilingTop=p.Results.CodeExecutionProfilingTop||p.Results.TopModelAccelWithTimeProfiling;
    lCodeStackProfilingTop=p.Results.CodeStackProfilingTop||p.Results.TopModelAccelWithStackProfiling;
    lCodeProfilingWCETAnalysis=p.Results.CodeProfilingWCETAnalysis;

    lTopOfBuildModel=p.Results.InstrumentationSettingsModel;


    IsTopModelXILSim=p.Results.TopModelXILSim;
    lTopModelSilOrPilBuild=p.Results.TopModelSilOrPilBuild||IsTopModelXILSim;
    lIsExtModeXCP=p.Results.IsExtModeXCP;




    lModelProfilingAllowed=loc_get_code_profiling_settings...
    (mdl,...
    activeConfigSet,...
    lTopOfBuildModel,...
    lTopModelStandalone,...
    lTopModelSilOrPilBuild,...
    lIsSimulationBuild,...
    lCodeExecutionProfilingTop,...
    lCodeStackProfilingTop,...
    lCodeProfilingWCETAnalysis,...
    lIsExtModeXCP);

    lXilInfo=rtw.pil.XilBuildArgs...
    (IsTopModelXILSim,...
    lTopModelSilOrPilBuild,p.Results.TopModelIsSilMode,...
    p.Results.SILModelReferences,...
    p.Results.PILModelReferences,...
    p.Results.SILModelReferencesTopModel,...
    p.Results.PILModelReferencesTopModel,...
    lTopModelStandalone,...
    mdl,...
    p.Results.SILDebugging,...
    lModelProfilingAllowed);

    simMode=get_param(mdl,'SimulationMode');
    stf=get_param(mdl,'SystemTargetFile');
    lIsRapidAccelerator=(~strcmp(get_param(mdl,'RapidAcceleratorSimStatus'),'inactive'));
    lIsRSim=isequal(stf,'rsim.tlc');
    lIsSimulinkAccelerator=(strcmp(simMode,'accelerator')&&isequal(stf,'accel.tlc'));


    requiredLicenses=coder.build.internal.checkoutLicensesForSlbuild(...
    lModelReferenceTargetType,lIsSimulinkAccelerator,lIsRapidAccelerator,mdl,lTopOfBuildModel);


    if lTopModelStandalone&&~lIsRapidAccelerator&&...
        (strcmp(get_param(mdl,'AutosarCompliant'),'on')||...
        Simulink.internal.isArchitectureModel(mdl,'AUTOSARArchitecture'))
        isTopModelAutosar=true;
        if~autosarinstalled()
            DAStudio.error('RTW:autosar:AUTOSARBlocksetNotAvailable',getfullname(mdl));
        end
        autosar.build.checkTopModelBuild(mdl,lXilInfo.IsTopModelXil,p.Results.GenerateCodeOnly);
    else
        isTopModelAutosar=false;
    end


    if isTopModelAutosar
        [isMappedToSubComponent,~]=Simulink.CodeMapping.isMappedToAutosarSubComponent(mdl);
        if isMappedToSubComponent
            DAStudio.error('autosarstandard:api:codegenNotSupportedForSubComp',mdl);
        end
        if~autosar.api.Utils.isMapped(mdl)
            autosar.validation.AutosarUtils.reportErrorWithFixit(...
            'Simulink:Engine:RTWCGAutosarEmptyConfigurationError',mdl);
        end
        arTopCodegenFolder=modelCodegenFolder;
        arTopComponent=autosar.api.Utils.m3iMappedComponent(mdl).Name;
    else
        arTopCodegenFolder='';
        arTopComponent='';

        if(lModelReferenceTargetType=="RTW")&&...
            strcmp(get_param(mdl,'AutosarCompliant'),'on')
            if Simulink.CodeMapping.isMappedToAutosarSubComponent(mdl)
                autosar.validation.ClassicSubComponentMappingValidator.validate(mdl);
            end
            autosar.validation.ClassicModelReferenceValidator.validate(mdl);
        end
    end

    lIsLibraryContextCodeGen=p.Results.IsLibraryContextCodeGen;

    if slfeature('ConfigSetActivator')
        altConfigSet=p.Results.ConfigSet;

        if get_param(mdl,'ParameterInheritance')=="Inherit"||...
            ~isempty(altConfigSet)||...
            (lModelReferenceTargetType=="SIM"||...
            lIsRapidAccelerator||...
            lXilInfo.IsTopModelSil)



            honoredParams={
'ModelReferenceNumInstancesAllowed'
'PropagateVarSize'
'ModelReferenceMinAlgLoopOccurrences'
'PropagateSignalLabelsOutOfModel'
'ModelReferencePassRootInputsByReference'
'ModelDependencies'
            };
            if isempty(altConfigSet)
                altConfigSet=getActiveConfigSet(mdl);
            end
            lConfigSetActivator=configset.internal.Activator(...
            {},altConfigSet,honoredParams);
            if altConfigSet~=getActiveConfigSet(mdl)
                lConfigSetActivator.activate(mdl);
            end
        else
            lConfigSetActivator=[];
        end
    else
        lConfigSetActivator=[];
    end




    lCodeCovSettings=p.Results.CodeCoverageSettings;
    if~isempty(lCodeCovSettings)&&~strcmp(lCodeCovSettings.CoverageTool,'None')
        if strcmp(lCodeCovSettings.CoverageTool,'Simulink Coverage')

            coverageSpec=@coder.internal.CodeInstrSpecCoverageSLNew;
        else

            coverageSpec=@coder.internal.CodeInstrSpecCoverageSL;
        end
        lCodeCoverageSpec=coverageSpec...
        (lCodeCovSettings,p.Results.InstrumentationSettingsModel,...
        lXilInfo.IsSil);
    end

    isERTSFuncTarget=~isempty(lXilInfo)&&lXilInfo.IsERTSfunction;


    if~isempty(p.Results.SlbDefaultCompInfo)
        lDefaultCompInfo=p.Results.SlbDefaultCompInfo;
    else




        lDefaultCompInfo=coder.internal.DefaultCompInfo.createDefaultCompInfo;
    end


    if strcmp(get_param(mdl,'GenerateGPUCode'),'CUDA')
        [licStatus,licMsg]=builtin('license','checkout','GPU_Coder');
        if~licStatus
            throw(MSLException([],message('gpucoder:system:GenerateGPUCodeOnWithNoLicense',licMsg,mdl)));
        end
    end
    if strcmp(get_param(mdl,'GPUAcceleration'),'on')
        [licStatus,licMsg]=builtin('license','checkout','GPU_coder');
        if~licStatus
            throw(MSLException([],message('gpucoder:system:GPUAccelerationOnWithNoLicense',licMsg,mdl)));
        end
    end



    if~isempty(p.Results.SlbModelCompInfo)
        lModelCompInfo=p.Results.SlbModelCompInfo;
    elseif lIsSimulationBuild

        lModelCompInfo=[];
    else
        allowLcc=loc_isBuildCompatibleWithLcc64(activeConfigSet,isERTSFuncTarget);
        lModelCompInfo=coder.internal.ModelCompInfo.createModelCompInfo...
        (mdl,lDefaultCompInfo.DefaultMexCompInfo,allowLcc);
    end

    lDefaultMexCompilerKey=lDefaultCompInfo.DefaultMexCompilerKey;
    lBaDefaultCompInfo=lDefaultCompInfo;
    lBaModelCompInfo=lModelCompInfo;
    if~isempty(p.Results.SlbXilCompInfo)
        lBaXilCompInfo=p.Results.SlbXilCompInfo;
    else
        lBaXilCompInfo=[];
    end
    lBaAutosarTwoPass=p.Results.SlbAutosarTwoPass;


    lDataflowMaxThreads=get_param(mdl,'DataflowSimMaxThreads');


    lModelRefAnchorCPUInfo=private_sl_CPUInfo;


    lSimVerbose=get_param(activeConfigSet,'AccelVerboseBuild');
    if isequal(lModelReferenceTargetType,'SIM')
        lVerbose=get_param(activeConfigSet,'AccelVerboseBuild');
    else
        lVerbose=get_param(activeConfigSet,'RTWVerbose');
    end
    lVerbose=isequal(lVerbose,'on');
    lSimVerbose=isequal(lSimVerbose,'on');


    try
        [lBuildHooks,lBuildHooksOnlyForERT]=...
        loc_get_build_hooks(mdl,lCodeCovSettings);
    catch e
        if strfind(e.identifier,'Simulink:ConfigSet:ConfigSetRef_GetParamOnUnresolvedReference')

            lBuildHooks=[];
        else
            rethrow(e)
        end
    end

    lSlbuildProfileIsOn=PerfTools.Tracer.enable('All Simulink Compile');
    lContextBasedBuild=subsystemreference.isContextBasedBuildAllowed(mdl);

    buildArgs=coder.build.internal.BuildArgs(...
    lTopModelStandalone,...
    arTopCodegenFolder,...
    arTopComponent,...
    lUpdateTopModelReferenceTarget,...
    p.Results.UpdateThisModelReferenceTarget,...
    lModelReferenceRTWTargetOnly,...
    lModelReferenceTargetType,...
    lProtectedModelReferenceTarget,...
    p.Results.ObfuscateCode,...
    p.Results.SubSystemBuild,...
    lGenerateMakefile,...
    lFirstModel,...
    lCodeCoverageSpec,...
    lCmdlSimInpInfo,...
    p.Results.UpdateDiagramOnly,...
    p.Results.ForceTopModelBuild,...
    p.Results.OpenBuildStatusAutomatically,...
    p.Results.LaunchCodeGenerationReport,...
    lIsExtModeOneClickSim,...
    lIsExtModeXCP,...
    p.Results.OkayToPushNags,...
    p.Results.StoredTFLChecksum,...
    p.Results.StoredChecksum,...
    lUseChecksum,...
    p.Results.StoredParameterChecksum,...
    p.Results.GenerateCodeOnly,...
    lCodeExecutionProfilingTop,...
    lCodeStackProfilingTop,...
    lCodeProfilingWCETAnalysis,...
    p.Results.CalledFromInsideSimulink,...
    p.Results.TopModelAccelWithTimeProfiling,...
    p.Results.TopModelAccelWithStackProfiling,...
    lIsRapidAccelerator,...
    lIsSimulinkAccelerator,...
    lIsLibraryContextCodeGen,...
    lIsRSim,...
    lConfigSetActivator,...
    lDefaultMexCompilerKey,...
    lBaDefaultCompInfo,...
    lBaModelCompInfo,...
    lBaXilCompInfo,...
    lBaAutosarTwoPass,...
    lDataflowMaxThreads,...
    lSlbuildProfileIsOn,...
    lXilInfo,...
    lContextBasedBuild,...
    lTopOfBuildModel,...
    lSimVerbose,...
    lVerbose,...
    lBuildHooks,...
    lBuildHooksOnlyForERT,...
    p.Results.OnlyCheckConfigsetMismatch,...
    p.Results.HardwareBuildFolders,...
    IsTopModelXILSim,...
    lCodeCovSettings,...
    p.Results.IncludeModelReferenceSimulationTargets,...
    requiredLicenses,...
    p.Results.IsXILSubsystemHiddenModelBuild,...
    lModelRefAnchorCPUInfo);

end

function loc_check_IncludeModelReferenceSimulationTargets(target,includeSimTargets)
    allowedTargets={'StandaloneRTWTarget','StandaloneCoderTarget'};
    isAllowedTarget=any(strcmp(target,allowedTargets));

    if(~isAllowedTarget&&includeSimTargets)
        DAStudio.error('Simulink:utility:invalidUseOfIncludeModelReferenceSimulationTargets');
    end
end

function loc_check_generateCodeCodeOnly(parser,buildSpec)

    if~any(strcmpi(parser.UsingDefaults,'GenerateCodeOnly'))
        generateCodeOnly=parser.Results.GenerateCodeOnly;
        validateattributes(generateCodeOnly,{'logical','numeric'},{'scalar','real'});

        genCodeOnlyCompatibleTarget=...
        any(strcmp(buildSpec,{'ModelReferenceTarget','ModelReferenceRTWTarget',...
        'ModelReferenceRTWTargetOnly','StandaloneRTWTarget',...
        'ModelReferenceCoderTarget','ModelReferenceCoderTargetOnly',...
        'StandaloneCoderTarget'}));

        if generateCodeOnly&&~genCodeOnlyCompatibleTarget
            DAStudio.error('Simulink:utility:invalidInputArgs','slbuild');
        end
    end
end

function loc_validateUpdateThisModelReferenceTarget(updateThisMdlRef)

    if~isempty(updateThisMdlRef)
        expected={'Force','IfOutOfDateOrStructuralChange','IfOutOfDate'};
        validPrm=any(strcmp(updateThisMdlRef,expected));
        if~validPrm
            DAStudio.error('Simulink:utility:slbuildInvalidPrmValForUpdateThisMdl');
        end
    end
end

function val=loc_getDefaultSILDebugging(mdl)


    lSILDebugging=strcmp(get_param(mdl,'SILDebugging'),'on');



    lIsBuildForTargetWithoutEC=coder.build.internal.isBuildForTargetWithoutEC(mdl);

    val=lSILDebugging&&~lIsBuildForTargetWithoutEC;

end

function val=loc_getDefaultCodeExecutionProfiling(mdl)


    lCodeExecutionProfiling=strcmp(get_param(mdl,'CodeExecutionProfiling'),'on');



    lIsBuildForTargetWithoutEC=coder.build.internal.isBuildForTargetWithoutEC(mdl);

    val=lCodeExecutionProfiling&&~lIsBuildForTargetWithoutEC;

end

function val=loc_getDefaultCodeStackProfiling(mdl)


    lCodeStackProfiling=logical(coder.profile.private.stackProfiling())&&...
    strcmp(get_param(mdl,'CodeStackProfiling'),'on');



    lIsBuildForTargetWithoutEC=coder.build.internal.isBuildForTargetWithoutEC(mdl);

    val=lCodeStackProfiling&&~lIsBuildForTargetWithoutEC;
end

function val=loc_getDefaultCodeProfilingWCETAnalysis(mdl)


    val=strcmp(get_param(mdl,'CodeExecutionProfiling'),'on')&&...
    strcmp(get_param(mdl,'CodeProfilingWCETAnalysis'),'on');
end

function[lBuildHooks,lBuildHooksOnlyForERT]=loc_get_build_hooks(mdl,codeCovSettings)





    lBuildHooks=coder.coverage.getBuildHooks(mdl);
    lBuildHooksOnlyForERT=lBuildHooks([]);







    lBuildHooks=coder.coverage.updateBuildHooks(codeCovSettings,lBuildHooks);

    if~isempty(lBuildHooks)





        modelRTWGenSettings=get_param(mdl,'RTWGenSettings');
        AccIsERTTarget='off';
        if~isempty(modelRTWGenSettings)&&...
            isfield(modelRTWGenSettings,'AccelIsERTTarget')

            AccIsERTTarget=modelRTWGenSettings.AccelIsERTTarget;
        end

        if~(strcmp(get_param(mdl,'IsERTTarget'),'on')||...
            strcmp(AccIsERTTarget,'on'))

            [~,coverageToolHookClasses]=coder.coverage.CodeCoverageHelper.getTools();

            [lBuildHooks,lBuildHooksOnlyForERT]=coder.coverage.bhFilterClasses...
            (lBuildHooks,coverageToolHookClasses);
        end
    end
end


function result=loc_isBuildCompatibleWithLcc64(cs,isERTSFuncTarget)

    result=false;

    if~ispc
        return;
    end


    if strcmpi('rtwsfcn.tlc',get_param(cs,'SystemTargetFile'))
        return;
    end

    if rtwprivate('rtw_is_cpp_build',cs)
        return;
    end

    toolchain=get_param(cs,'Toolchain');
    if isERTSFuncTarget

        if strncmp(toolchain,'LCC-win64',length('LCC-win64'))
            DAStudio.error('RTW:buildProcess:unsupportedCompilerForERTSFunc')
        end
        return;
    end
    if strcmp(toolchain,coder.make.internal.getInfo('default-toolchain'))...
        ||strncmp(toolchain,'LCC-win64',length('LCC-win64'))
        result=true;
    end
end



function lSILPILModelProfilingAllowed=loc_get_code_profiling_settings...
    (mdl,...
    activeConfigSet,...
    lTopOfBuildModel,...
    lTopModelStandalone,...
    lTopModelPILBuild,...
    isSimulationBuild,...
    lCodeExecutionProfilingTop,...
    lCodeStackProfilingTop,...
    lCodeProfilingWCETAnalysis,...
    lIsExtModeXCP)

    lSILPILModelProfilingAllowed=false;

    if coder.build.internal.isBuildForTargetWithoutEC(mdl)

        return;
    end

    if(ecoderinstalled()&&strcmp(get_param(mdl,'IsERTTarget'),'on'))

        if lTopModelStandalone
            if(lTopModelPILBuild)
                lSILPILModelProfilingAllowed=true;
            else
                createSILPILBlock=rtwprivate('isCreateSILPILBlock',...
                activeConfigSet);
                lSILPILModelProfilingAllowed=createSILPILBlock;
            end
        end
    end

    coder.internal.checkTopModelProfilingConfig(mdl,lTopOfBuildModel,...
    lTopModelStandalone,...
    lTopModelPILBuild,...
    isSimulationBuild,...
    lCodeExecutionProfilingTop,...
    lCodeStackProfilingTop,...
    lCodeProfilingWCETAnalysis,...
    lIsExtModeXCP);

end





