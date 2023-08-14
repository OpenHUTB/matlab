function setupReportData(obj)




    if~obj.getOptions().GenerateReport
        return;
    end


    configStructsVec=newEmptyConfigStruct();
    configRedIdx=1;
    modelInfoVec=obj.ProcessedModelInfoStructsVec;


    fields=fieldnames(configStructsVec);



    fields=setdiff(fields,{'ModelName'});

    for mdlId=1:numel(modelInfoVec)
        configs=modelInfoVec(mdlId).ConfigInfos;
        for configId=1:numel(configs)
            if isempty(configs(configId).Configuration)
                continue;
            end
            for fIdx=1:numel(fields)
                configStructsVec(configRedIdx).(fields{fIdx})=...
                configs(configId).Configuration.(fields{fIdx});
            end
            configStructsVec(configRedIdx).ModelName=modelInfoVec(mdlId).OrigName;
            configRedIdx=configRedIdx+1;
        end
    end
    obj.ReportDataObj.Configurations=configStructsVec;


    obj.ReportDataObj.BlocksRemoved=[...
    getRemovedBlocks(obj.ModelRefModelInfoStructsVec,false);...
    getRemovedBlocks(obj.LibInfoStructsVec,true)];


    obj.ReportDataObj.BlocksAdded=getAllAddedBlocks({obj.ProcessedModelInfoStructsVec.Name});


    obj.ReportDataObj.Warnings=obj.Warnings;
end

function configStruct=newEmptyConfigStruct()
    configStruct=struct('Name','',...
    'Description','',...
    'ControlVariables',[],...
    'SubModelConfigurations',[],...
    'ModelName','');
    controlVars=struct('Name','','Value',[]);
    controlVars(end)=[];
    configStruct.ControlVariables=controlVars;
    subModelConfigs=struct('ModelName','','ConfigurationName','');
    subModelConfigs(end)=[];
    configStruct.SubModelConfigurations=subModelConfigs;
    configStruct(end)=[];
end



function addedBlks=getAllAddedBlocks(redMdlNames)


    addedBlks.addedSS=find_system(redMdlNames,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','SignalSpecification',...
    'Tag','VariantReducer_SignalSpecification');


    addedBlks.addedGnds=find_system(redMdlNames,'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','Ground',...
    'Tag','VariantReducer_Ground');


    addedBlks.addedTerms=find_system(redMdlNames,'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','Terminator',...
    'Tag','VariantReducer_Terminator');


    addedBlks.addedConstants=find_system(redMdlNames,'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','Constant',...
    'Tag','VariantReducer_Constant');

    addedBlks.addedLabelModeSISOVariantSources=find_system(redMdlNames,'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','VariantSource',...
    'Tag','VariantReducer_LabelModeSISOVariantSource');

    addedBlks.addedBusSubsystems=find_system(redMdlNames,'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','SubSystem',...
    'Tag','VariantReducer_BusObject');


    addedBlks.addedSS=i_replaceCarriageReturnWithSpace(addedBlks.addedSS);
    addedBlks.addedGnds=i_replaceCarriageReturnWithSpace(addedBlks.addedGnds);
    addedBlks.addedTerms=i_replaceCarriageReturnWithSpace(addedBlks.addedTerms);
    addedBlks.addedConstants=i_replaceCarriageReturnWithSpace(addedBlks.addedConstants);
    addedBlks.addedLabelModeSISOVariantSources=i_replaceCarriageReturnWithSpace(addedBlks.addedLabelModeSISOVariantSources);


    if~isempty(addedBlks.addedBusSubsystems)
        addedBlks.addedBusSubsystems=getAddedBusBlocks(addedBlks.addedBusSubsystems);
    end

end


function removedBlockStructsVec=getRemovedBlocks(bdVec,isLib)
    removedBlockStructsVec=newEmptyRemovedBlocksStruct();
    for bdId=1:numel(bdVec)
        allBlks=bdVec(bdId).BlksSVCEMap.keys';
        delIdx=logical(~Simulink.variant.utils.i_cell2mat(bdVec(bdId).BlksSVCEMap.values)');
        removedBlocksCurr=allBlks(delIdx);
        removedBlocksCurr=strrep(removedBlocksCurr,bdVec(bdId).Name,bdVec(bdId).OrigName);
        removedBlockStructsVec(bdId).ModelName=bdVec(bdId).OrigName;
        removedBlockStructsVec(bdId).isLibrary=isLib;
        removedBlockStructsVec(bdId).BlockPaths=removedBlocksCurr;
    end
end

function remBlockStruct=newEmptyRemovedBlocksStruct()
    remBlockStruct=struct('ModelName','',...
    'BlockPaths',[],...
    'isLibrary',[]);
    remBlockStruct(end)=[];
end

function busSSBlocksStruct=getAddedBusBlocks(busSSBlocks)

    busSSBlocksStruct(1,numel(busSSBlocks))=getNewEmptyBusSSBlocksStruct();

    for ii=1:numel(busSSBlocks)

        busSSBlocksStruct(ii).Block=i_replaceCarriageReturnWithSpace(busSSBlocks{ii});
        busSSBlocksStruct(ii).Constant=[busSSBlocksStruct(ii).Block,'/Constant'];
        busSSBlocksStruct(ii).SignalConversion='';
        busSSBlocksStruct(ii).Outport=[busSSBlocksStruct(ii).Block,'/Out1'];

        sigCovBlk=find_system(busSSBlocks{ii},...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'BlockType','SignalConversion',...
        'Tag','VariantReducer_BusObject');
        if~isempty(sigCovBlk)
            busSSBlocksStruct(ii).SignalConversion=[busSSBlocksStruct(ii).Block,'/SignalConversion'];
        end
    end

end

function busSSstruct=getNewEmptyBusSSBlocksStruct()
    busSSstruct=struct('Block','',...
    'Constant','',...
    'SignalConversion','',...
    'Outport','');
end


