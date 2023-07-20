function harnessInfo=generateHarnessCreateDefaults(harnessInfo,cm,customizationsEnabled)






    harnessInfoFile=[harnessInfo.model,'_harnessInfo.xml'];
    harnessInfo=Simulink.harness.internal.getHarnessInfoDefaults(...
    harnessInfo,harnessInfoFile);
    ownerUDD=get_param(harnessInfo.ownerHandle,'Object');


    harnessInfo.param.saveExternally=getSaveExtDefault(harnessInfo.model,...
    customizationsEnabled,...
    cm);





    if((isa(ownerUDD,'Simulink.BlockDiagram')&&strcmpi(get_param(ownerUDD.Handle,'IsExportFunctionModel'),'on'))||...
        (isa(ownerUDD,'Simulink.ModelReference')&&strcmpi(get_param(ownerUDD.Handle,'IsModelRefExportFunction'),'on')))
        harnessInfo.param.schedulerBlock="Test Sequence";
    elseif isa(ownerUDD,'Simulink.SubSystem')||Simulink.harness.internal.isUserDefinedFcnBlock(harnessInfo.ownerHandle)
        harnessInfo.param.schedulerBlock="Test Sequence";
    elseif isa(ownerUDD,'Simulink.ModelReference')&&...
        strcmpi(get_param(ownerUDD.Handle,'ShowModelPeriodicEventPorts'),'on')
        harnessInfo.param.schedulerBlock='Test Sequence';
    else
        harnessInfo.param.schedulerBlock='None';
    end


    if customizationsEnabled
        hCreateCustomizerObj=cm.SimulinkTestCustomizer.createHarnessDefaultsObj;

        harnessInfo.name=Simulink.harness.internal.customDefaultsUtils.getDefaultName(...
        harnessInfo.ownerFullPath,harnessInfo.model,hCreateCustomizerObj);



        harnessInfo.description=char(hCreateCustomizerObj.Description);


        if any(strcmpi("Source",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.source=hCreateCustomizerObj.Source;
        end

        if any(strcmpi("Sink",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.sink=hCreateCustomizerObj.Sink;
        end





        if any(strcmpi("SynchronizationMode",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.synchronizationMode=hCreateCustomizerObj.SynchronizationMode;
        end


        if any(strcmpi("HarnessPath",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.fileName=char(hCreateCustomizerObj.HarnessPath);
        end


        if any(strcmpi("SeparateAssessment",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.separateAssessment=hCreateCustomizerObj.SeparateAssessment;
        end


        if any(strcmpi("CreateWithoutCompile",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.createGraphicalHarness=hCreateCustomizerObj.CreateWithoutCompile;
        end


        if any(strcmpi("RebuildOnOpen",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.rebuildOnOpen=hCreateCustomizerObj.RebuildOnOpen;
        end


        if any(strcmpi("LogOutputs",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.logHarnessOutputs=hCreateCustomizerObj.LogOutputs;
        end


        if any(strcmpi("RebuildModelData",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.rebuildModelData=hCreateCustomizerObj.RebuildModelData;
        end


        if any(strcmpi("ScheduleInitTermReset",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.scheduleInitTermReset=hCreateCustomizerObj.ScheduleInitTermReset;
        end


        if any(strcmpi("SchedulerBlock",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.schedulerBlock=hCreateCustomizerObj.SchedulerBlock;
        end


        if any(strcmpi("AutoShapeInputs",hCreateCustomizerObj.userDefinedProps))
            harnessInfo.param.autoShapeInputs=hCreateCustomizerObj.AutoShapeInputs;
        end



        harnessInfo.param.postRebuildCallBack=...
        char(hCreateCustomizerObj.PostRebuildCallback.strip);


        harnessInfo.param.customSourcePath=char(hCreateCustomizerObj.CustomSourcePath.strip);
        harnessInfo.param.customSinkPath=char(hCreateCustomizerObj.CustomSinkPath.strip);


        harnessInfo.param.verificationMode=hCreateCustomizerObj.VerificationMode.strip;

    else

        harnessInfo.name=Simulink.harness.internal.getDefaultName(...
        harnessInfo.model,harnessInfo.ownerFullPath,[]);
    end


end

function saveExtDefault=getSaveExtDefault(ownerModel,customizationsEnabled,cm)
    saveExternallyMode=...
    Simulink.harness.internal.getHarnessCreationCheckboxMode.saveExtCheckboxMode(ownerModel);
    switch saveExternallyMode




    case Simulink.harness.internal.getHarnessCreationCheckboxMode.ALLOW_SELECTION
        if customizationsEnabled
            saveExtDefault=cm.SimulinkTestCustomizer.createHarnessDefaultsObj.SaveExternally;
        else
            saveExtDefault=false;
        end
    otherwise
        saveExtDefault=...
        saveExternallyMode==Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_EXTERNALLY;
    end

end