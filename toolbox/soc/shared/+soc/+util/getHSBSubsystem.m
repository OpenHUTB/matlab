


function[fpgaModelBlock,fpgaModel]=getHSBSubsystem(sys)



    fpgaModelBlock='';
    if slfeature('FindSystemVariantsRemoval')>0





        [~,mdlblks]=find_mdlrefs(sys,'AllLevels',false,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    else
        [~,mdlblks]=find_mdlrefs(sys,'AllLevels',false,'Variants','ActiveVariants');
    end
    if~isempty(mdlblks)
        for ii=1:numel(mdlblks)
            thisMdlBlk=mdlblks{ii};
            thisMdlRefFile=get_param(thisMdlBlk,'ModelFile');
            isProtected=slInternal('getReferencedModelFileInformation',thisMdlRefFile);
            if~isProtected
                thisMdlRefName=get_param(thisMdlBlk,'ModelName');
                load_system(thisMdlRefName);
                cs=getActiveConfigSet(thisMdlRefName);
            else
                [~,thisMdlRefName,~]=fileparts(thisMdlRefFile);
                cs=Simulink.ProtectedModel.getConfigSet(thisMdlRefName);
            end

            isFPGAmdlref=strcmpi(get_param(cs,'HardwareBoard'),'None')&&strcmpi(get_param(cs,'ProdHWDeviceType'),'ASIC/FPGA->ASIC/FPGA');
            if isFPGAmdlref
                if~isempty(fpgaModelBlock)
                    error(message('soc:msgs:MultFPGAModel',sys));
                else
                    fpgaModelBlock=thisMdlBlk;
                end
            end
        end
    end

    if isempty(fpgaModelBlock)
        fpgaModel='';
    else
        fpgaModel=get_param(fpgaModelBlock,'ModelName');
    end
end

