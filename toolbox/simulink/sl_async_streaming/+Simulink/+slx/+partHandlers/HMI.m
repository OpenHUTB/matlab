function h=HMI





    try
        Simulink.HMI.initStreamingSubscribers();
        Simulink.HMI.WebHMI.registerHMIWebBlocks();


        h=Simulink.slx.PartHandler(...
        'hmi',...
        Simulink.HMI.Utils.FileKeeper.HMI_PARENT_ID,...
        @i_load,@i_save);


        mgr=Simulink.HMI.InterfaceMgr.getInterfaceMgr();
        mgr.setGetWebHMIMethod(@Simulink.HMI.WebHMI.getWebHMI);
    catch
        h=[];
    end
end

function i_load(modelHandle,loadOptions)
    harnessID=get_param(modelHandle,'HarnessID');
    if~Simulink.harness.isHarnessBD(modelHandle)||isempty(harnessID)
        webhmiTarget=Simulink.HMI.Utils.FileKeeper.getWebHMIRelTarget();
        locCheckAndInitializeWebHMI(modelHandle,loadOptions,webhmiTarget);
    else
        locLoadWebHMIForHarness(modelHandle,loadOptions,harnessID);
    end
end

function i_save(modelHandle,saveOptions)
    webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
    if~isempty(webhmi)
        priorName=webhmi.Model;

        mdlname=get_param(modelHandle,'Name');
        if~strcmp(priorName,mdlname)
            webhmi.Model=mdlname;
        end
        harnessID=get_param(modelHandle,'HarnessID');
        if~Simulink.harness.isHarnessBD(modelHandle)||isempty(harnessID)
            fileName=Simulink.HMI.Utils.FileKeeper.getWebHMITarget(mdlname);
            partDef=locGetWebHMIPartForModel;
        else

            fileName=Simulink.HMI.Utils.FileKeeper.getWebHMIHarnessTarget(modelHandle,harnessID);
            partDef=locGetWebHMIPartForHarness(harnessID);
        end

        locCheckAndSavePart(saveOptions,webhmi,partDef,fileName)
    end
end

function locLoadWebHMIForHarness(modelHandle,loadOptions,harnessId)
    modelName=get_param(modelHandle,'Name');
    if Simulink.HMI.WebHMI.hasWebHMIWithName(modelName)
        oldHandle=Simulink.HMI.WebHMI.moveWebHMIToNewHandle(modelName,modelHandle);
        simulink.hmi.listeners_manager('remove',oldHandle);
        simulink.hmi.listeners_manager('add',omodelHandle);
        mgr=Simulink.PluginMgr();
        mgr.attach(modelHandle,'sl_hmi_plugin',true);
    else
        webhmiTarget=Simulink.HMI.Utils.FileKeeper.getWebHMIHarnessRelTarget(harnessId);
        locCheckAndInitializeWebHMI(modelHandle,loadOptions,webhmiTarget);
    end
end

function locCheckAndInitializeWebHMI(modelHandle,loadOptions,partName)
    if~loadOptions.readerHandle.hasPart(partName)
        return;
    end

    targetFileName=Simulink.slx.getUnpackedFileNameForPart(modelHandle,partName);
    loadOptions.readerHandle.readPartToFile(partName,targetFileName);

    if exist(targetFileName,'file')
        modelName=get_param(modelHandle,'Name');
        webhmi=Simulink.HMI.WebHMI.createNewWebHMI(modelHandle,...
        modelName);
        try
            modelRelease=simulink_version(get_param(modelHandle,'VersionLoaded')).release;
        catch
            modelRelease='';
        end

        if isequal(modelRelease,'R2015a')
            webhmi.load(targetFileName,0);
        else
            webhmi.load(targetFileName);
        end
        simulink.hmi.listeners_manager('add',modelHandle);
        mgr=Simulink.PluginMgr();
        mgr.attach(modelHandle,'sl_hmi_plugin',true);
    end
end

function part=locGetWebHMIPartForModel
    webhmiRelTarget=Simulink.HMI.Utils.FileKeeper.getWebHMIRelTarget();
    webhmiID=Simulink.HMI.Utils.FileKeeper.WEBHMI_ID;
    part=Simulink.loadsave.SLXPartDefinition(...
    webhmiRelTarget,...
    Simulink.HMI.Utils.FileKeeper.HMI_PARENT_IN_SLX,...
    Simulink.HMI.Utils.FileKeeper.WEBHMI_CONTENT_TYPE,...
    Simulink.HMI.Utils.FileKeeper.WEBHMI_REL,...
    webhmiID);
end

function part=locGetWebHMIPartForHarness(id)
    webhmiRelTarget=Simulink.HMI.Utils.FileKeeper.getWebHMIHarnessRelTarget(id);
    webhmiRelId=Simulink.HMI.Utils.FileKeeper.getWebHMIHarnessRelId(id);
    webhmiID=[id,'_webhmi'];
    part=Simulink.loadsave.SLXPartDefinition(...
    webhmiRelTarget,...
    Simulink.HMI.Utils.FileKeeper.TEST_HARNESS_PARENT_PART,...
    Simulink.HMI.Utils.FileKeeper.WEBHMI_CONTENT_TYPE,...
    webhmiRelId,...
    webhmiID);
end

function locCheckAndSavePart(saveOptions,webhmi,partDef,fileName)

    writer=saveOptions.writerHandle;
    try
        hmiPartExists=writer.hasPart(partDef.name);
    catch me %#ok<NASGU>
        hmiPartExists=false;
    end


    if hmiPartExists&&saveOptions.isExportingToReleaseOrOlder('R2014b')
        writer.deletePart(partDef);

    elseif~isempty(webhmi.WidgetIDs)||...
        ~isempty(webhmi.getLibraryWidgetIdsToSave())
        if hmiPartExists&&saveOptions.isExportingToReleaseOrOlder('R2015a')
            webhmi.save(fileName,saveOptions.isAutosave,0);
        else
            webhmi.save(fileName,saveOptions.isAutosave);
        end
        writer.writePartFromFile(partDef,fileName);

    elseif hmiPartExists
        writer.deletePart(partDef);
    end
end


