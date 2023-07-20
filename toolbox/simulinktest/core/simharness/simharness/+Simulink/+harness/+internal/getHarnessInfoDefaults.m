function harnessInfo=getHarnessInfoDefaults(harnessInfo,harnessInfoFile)




    ownerUDD=get_param(harnessInfo.ownerHandle,'Object');

    harnessInfo.name='';
    harnessInfo.type=0;
    harnessInfo.description='';
    harnessInfo.param.source=Simulink.harness.internal.TestHarnessSourceTypes.INPORT.name;
    harnessInfo.param.sink=Simulink.harness.internal.TestHarnessSinkTypes.OUTPORT.name;
    harnessInfo.param.separateAssessment=false;
    harnessInfo.param.logHarnessOutputs=false;

    isLibHarness=bdIsLibrary(harnessInfo.model);
    isSubsystemModel=bdIsSubsystem(harnessInfo.model);
    if isLibHarness||isSubsystemModel
        harnessInfo.param.createGraphicalHarness=true;
    else
        harnessInfo.param.createGraphicalHarness=false;
    end
    harnessInfo.createFromDialog=Simulink.harness.internal.CreateFromDialogFlag();
    harnessInfo.name=Simulink.harness.internal.getDefaultName(...
    harnessInfo.model,harnessInfo.ownerFullPath,[]);
    harnessInfo.param.verificationMode=0;
    harnessInfo.param.customSourcePath='';
    harnessInfo.param.customSinkPath='';
    harnessInfo.param.driveFcnCallWithTS=true;
    harnessInfoFileExists=(exist(harnessInfoFile,'file')==2);
    modelFileName=get_param(harnessInfo.model,'FileName');
    [~,~,fileExt]=fileparts(modelFileName);
    isMDLFile=strcmpi(fileExt,'.mdl');
    isInSLDVExtractMode=slsvTestingHook('UnifiedHarnessBackendMode')>0;


    harnessInfo.param.saveExternally=(harnessInfoFileExists||(isMDLFile&&~isInSLDVExtractMode));
    harnessInfo.param.fileName='';
    harnessInfo.param.usedSignalsOnly=false;


    harnessInfo.param.scheduleInitTermReset=false;


    harnessInfo.param.schedulePeriodicEventPorts=false;

    harnessInfo.param.rebuildOnOpen=false;
    harnessInfo.param.existingBuildFolder='';
    harnessInfo.param.rebuildModelData=false;

    import Simulink.harness.internal.TestHarnessSourceTypes;
    import Simulink.harness.internal.TestHarnessSinkTypes;


    if isLibHarness

        if strcmp(harnessInfo.ownerFullPath,harnessInfo.model)
            DAStudio.error('Simulink:Harness:HarnessCannotBeCreatedForALibraryMdl');
        end
    end

    harnessInfo.param.postCreateCallBack='';
    harnessInfo.param.postRebuildCallBack='';

    harnessInfo.param.autoShapeInputs=false;


    harnessInfo.param.UsedSignalsCell={};







    synchronizationModes={'SyncOnOpenAndClose','SyncOnOpen','SyncOnPushRebuildOnly'};
    if(isa(ownerUDD,'Simulink.BlockDiagram')||...
        isCreatingForImplicitLink(harnessInfo.ownerHandle))||...
        Simulink.internal.isArchitectureModel(harnessInfo.model)
        harnessInfo.param.synchronizationMode=synchronizationModes{2};
    else
        harnessInfo.param.synchronizationMode=synchronizationModes{1};
    end

end

function r=isCreatingForImplicitLink(ownerHandle)
    r=false;
    if ishandle(ownerHandle)&&strcmp(get_param(ownerHandle,'Type'),'block')
        r=Simulink.harness.internal.isImplicitLink(ownerHandle);
    end
end
