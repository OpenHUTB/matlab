function autosarBlocks=getAutosarBlockSupportTable(PCGCompatibilityFlag)






    if nargin<1
        PCGCompatibilityFlag=true;
    end

    persistent allowedBlkTypes;
    persistent prohibitedBlkTypes;

    if isempty(allowedBlkTypes)
        allowedBlkTypes=cell(8,2);
        allowedBlkTypes(:,1)={'Inport','Outport','Receive','Send'...
        ,'SignalInvalidation','SubSystem','SubSystem','SubSystem'};
        allowedBlkTypes(:,2)={''};
        allowedBlkTypes(7:8,2)={'Event Receive','Event Send'};
        prohibitedBlkTypes=[];
    end

    if PCGCompatibilityFlag
        autosarBlocks=allowedBlkTypes;
    else
        autosarBlocks=prohibitedBlkTypes;
    end

end




function getAutosarBlocksDynamically
    [allowedBlkTypes,prohibitedBlkTypes]=...
    Advisor.Utils.Simulink.block.getBlockTypeListFromLibrary(...
    'autosarlib',...
    {'autosarlibcprouting','autosarlibaprouting'});
    allowedBlkTypes=unique(allowedBlkTypes);
    prohibitedBlkTypes=unique(prohibitedBlkTypes);
    allowedBlkTypes=Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(allowedBlkTypes);
    prohibitedBlkTypes=Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(prohibitedBlkTypes);
end