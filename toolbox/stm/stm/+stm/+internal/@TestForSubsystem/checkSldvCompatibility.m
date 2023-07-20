function[useTempHrnsForTestGen,hasEnhancedMCDCEnabled]=checkSldvCompatibility(subsys,topModelName,fcnInterfaceName,createForTopModel)



    subsys=string(subsys);
    topModelName=string(topModelName);
    useTempHrnsForTestGen=false;

    if~contains(subsys,"/")&&~createForTopModel
        subsys=topModelName+"/"+subsys;
    end

    subModel=stm.internal.TestForSubsystem.getSubsystemInfo(subsys,topModelName);


    if~bdIsLoaded(subModel)
        load_system(subModel);
        oc=onCleanup(@()close_system(subModel));
    end

    blkHdl=get_param(subsys,'Handle');


    if~Simulink.SubsystemType.isBlockDiagram(blkHdl)
        blockType=string(get_param(blkHdl,'BlockType'));


        useTempHrnsForTestGen=any(stm.internal.TestForSubsystem.BlockTypesReqTempHrns==blockType)...
        ||~isempty(fcnInterfaceName)||bdIsLibrary(subModel);
        if~useTempHrnsForTestGen

            errMsg=sldvprivate('cmd_resolveobj',blkHdl);
            if~isempty(errMsg)
                error(message('stm:CoverageStrings:CovTopOff_Error_SldvError',errMsg));
            end
        end
    end

    if isempty(fcnInterfaceName)
        if createForTopModel||~strcmp(get_param(subsys,'BlockType'),'ModelReference')
            modelToUse=topModelName;
        else

            modelToUse=string(get_param(subsys,'ModelName'));

            if~bdIsLoaded(modelToUse)
                ocp=onCleanup(@()close_system(modelToUse));
                load_system(modelToUse);
            end
        end
    else

        if~bdIsLoaded(fcnInterfaceName)
            Simulink.libcodegen.internal.loadCodeContext(subsys.char,fcnInterfaceName);
            ocp=onCleanup(@()close_system(fcnInterfaceName));
        end
        modelToUse=fcnInterfaceName;
    end
    hasEnhancedMCDCEnabled=locGetSLDVEnhancedMCDCSettingStatus(modelToUse);
end

function status=locGetSLDVEnhancedMCDCSettingStatus(modelName)
    status=false;
    cfg=getActiveConfigSet(modelName);
    components=cfg.Components;
    ind=arrayfun(@(x)strcmp(x.Name,'Design Verifier'),components);
    if any(ind)
        status=strcmp(components(ind).DVModelCoverageObjectives,'EnhancedMCDC');
    end
end