classdef BuildArgs<handle







    properties(GetAccess=public,SetAccess=immutable)
TopModelStandalone
AutosarTopCodegenFolder
AutosarTopComponent
StandaloneTopModelName
UpdateThisModelReferenceTarget
ModelReferenceRTWTargetOnly
ObfuscateCode
SubSystemBuild
CodeCoverageSpec
CmdlSimInpInfo
IsUpdateDiagramOnly
ForceTopModelBuild
OpenBuildStatusAutomatically
LaunchCodeGenerationReport
IsExtModeOneClickSim
IsExtModeXCP
OkayToPushNags
CodeExecutionProfilingTop
CodeStackProfilingTop
CodeProfilingWCETAnalysis
CalledFromInsideSimulink
TopModelAccelWithTimeProfiling
TopModelAccelWithStackProfiling
IsRapidAccelerator
IsSimulinkAccelerator
IsLibraryContextCodeGen
IsRSim
ConfigSetActivator
DefaultMexCompilerKey
BaDefaultCompInfo
BaXilCompInfo
BaAutosarTwoPass
DataflowMaxThreads
SlbuildProfileIsOn
XilInfo
LibraryBuild
TopOfBuildModel
SimVerbose
BuildHooksOnlyForERT
OnlyCheckConfigsetMismatch
UseHardwareBuildFolders
IsTopModelXILSim
CodeCoverageSettings
IncludeModelReferenceSimulationTargets
RequiredLicenses
IsXILSubsystemHiddenModelBuild
ModelRefAnchorCPUInfo
    end




    properties(Transient,SetAccess=private)
BuildSummary
    end



    properties(Access=public)
StoredParameterChecksum
StoredTFLChecksum
StoredChecksum
UseChecksum
FirstModel
DispHook
MdlRefsUpdated
hasModelBlocks
Verbose
SimulationInputInfo
ModelReferenceTargetType
BaGenerateCodeOnly
IsUpdatingSimForRTW
Bsn
UpdateTopModelReferenceTarget
BaModelCompInfo
BaGenerateMakefile
ProtectedModelReferenceTarget
BuildHooks
XilTopModel
    end

    methods
        function this=BuildArgs(...
            topModelStandalone,...
            arTopCodegenFolder,...
            arTopComponent,...
            updateTopModelReferenceTarget,...
            updateThisModelReferenceTarget,...
            modelReferenceRTWTargetOnly,...
            modelReferenceTargetType,...
            protectedModelReferenceTarget,...
            obfuscateCode,...
            subSystemBuild,...
            baGenerateMakefile,...
            firstModel,...
            codeCoverageSpec,...
            cmdlSimInpInfo,...
            isUpdateDiagramOnly,...
            forceTopModelBuild,...
            openBuildStatusAutomatically,...
            launchCodeGenerationReport,...
            isExtModeOneClickSim,...
            isExtModeXCP,...
            okayToPushNags,...
            storedTFLChecksum,...
            storedChecksum,...
            useChecksum,...
            storedParameterChecksum,...
            generateCodeOnly,...
            codeExecutionProfilingTop,...
            codeStackProfilingTop,...
            codeProfilingWCETAnalysis,...
            calledFromInsideSimulink,...
            topModelAccelWithTimeProfiling,...
            topModelAccelWithStackProfiling,...
            isRapidAccelerator,...
            isSimulinkAccelerator,...
            isLibraryContextCodeGen,...
            isRSim,...
            configSetActivator,...
            defaultMexCompilerKey,...
            baDefaultCompInfo,...
            baModelCompInfo,...
            baXilCompInfo,...
            baAutosarTwoPass,...
            dataflowMaxThreads,...
            slbuildProfileIsOn,...
            xilInfo,...
            libraryBuild,...
            topOfBuildModel,...
            simVerbose,...
            verbose,...
            buildHooks,...
            buildHooksOnlyForERT,...
            onlyCheckConfigsetMismatch,...
            useHardwareBuildFolders,...
            isTopModelXILSim,...
            codeCoverageSettings,...
            includeModelReferenceSimulationTargets,...
            requiredLicenses,...
            isXILSubsystemHiddenModelBuild,...
            ModelRefAnchorCPUInfo)

            this.TopModelStandalone=topModelStandalone;
            this.AutosarTopCodegenFolder=arTopCodegenFolder;
            this.AutosarTopComponent=arTopComponent;
            this.UpdateTopModelReferenceTarget=updateTopModelReferenceTarget;
            this.UpdateThisModelReferenceTarget=updateThisModelReferenceTarget;
            this.ModelReferenceRTWTargetOnly=modelReferenceRTWTargetOnly;
            this.ModelReferenceTargetType=modelReferenceTargetType;
            this.ProtectedModelReferenceTarget=protectedModelReferenceTarget;
            this.ObfuscateCode=obfuscateCode;
            this.SubSystemBuild=subSystemBuild;
            this.BaGenerateMakefile=baGenerateMakefile;
            this.FirstModel=firstModel;
            this.CodeCoverageSpec=codeCoverageSpec;
            this.CmdlSimInpInfo=cmdlSimInpInfo;
            this.IsUpdateDiagramOnly=isUpdateDiagramOnly;
            this.ForceTopModelBuild=forceTopModelBuild;
            this.OpenBuildStatusAutomatically=openBuildStatusAutomatically;
            this.LaunchCodeGenerationReport=launchCodeGenerationReport;
            this.IsExtModeOneClickSim=isExtModeOneClickSim;
            this.IsExtModeXCP=isExtModeXCP;
            this.OkayToPushNags=okayToPushNags;
            this.StoredTFLChecksum=storedTFLChecksum;
            this.StoredChecksum=storedChecksum;
            this.UseChecksum=useChecksum;
            this.StoredParameterChecksum=storedParameterChecksum;
            this.BaGenerateCodeOnly=generateCodeOnly;
            this.CodeExecutionProfilingTop=codeExecutionProfilingTop;
            this.CodeStackProfilingTop=codeStackProfilingTop;
            this.CodeProfilingWCETAnalysis=codeProfilingWCETAnalysis;
            this.CalledFromInsideSimulink=calledFromInsideSimulink;
            this.TopModelAccelWithTimeProfiling=topModelAccelWithTimeProfiling;
            this.TopModelAccelWithStackProfiling=topModelAccelWithStackProfiling;
            this.IsRapidAccelerator=isRapidAccelerator;
            this.IsSimulinkAccelerator=isSimulinkAccelerator;
            this.IsLibraryContextCodeGen=isLibraryContextCodeGen;
            this.IsRSim=isRSim;
            this.ConfigSetActivator=configSetActivator;
            this.DefaultMexCompilerKey=defaultMexCompilerKey;
            this.BaDefaultCompInfo=baDefaultCompInfo;
            this.BaModelCompInfo=baModelCompInfo;
            this.BaXilCompInfo=baXilCompInfo;
            this.BaAutosarTwoPass=baAutosarTwoPass;
            this.DataflowMaxThreads=dataflowMaxThreads;
            this.SlbuildProfileIsOn=slbuildProfileIsOn;
            this.XilInfo=xilInfo;
            this.LibraryBuild=libraryBuild;
            this.TopOfBuildModel=topOfBuildModel;
            this.SimVerbose=simVerbose;
            this.Verbose=verbose;
            this.BuildHooks=buildHooks;
            this.BuildHooksOnlyForERT=buildHooksOnlyForERT;
            this.OnlyCheckConfigsetMismatch=onlyCheckConfigsetMismatch;
            this.UseHardwareBuildFolders=useHardwareBuildFolders;
            this.IsTopModelXILSim=isTopModelXILSim;
            this.CodeCoverageSettings=codeCoverageSettings;
            this.IncludeModelReferenceSimulationTargets=includeModelReferenceSimulationTargets;
            this.IsXILSubsystemHiddenModelBuild=isXILSubsystemHiddenModelBuild;
            this.ModelRefAnchorCPUInfo=ModelRefAnchorCPUInfo;
            this.initializeBuildSummary;
            this.RequiredLicenses=requiredLicenses;
        end

        function delete(this)
            if slfeature('ConfigSetActivator')
                delete(this.ConfigSetActivator);
            end
        end
    end

    methods(Hidden)
        function initializeBuildSummary(this)
            this.BuildSummary=coder.build.internal.BuildSummary;
        end
    end
end

