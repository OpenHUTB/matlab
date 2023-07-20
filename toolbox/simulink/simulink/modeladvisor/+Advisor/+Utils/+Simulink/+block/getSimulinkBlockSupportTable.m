
function output=getSimulinkBlockSupportTable(PCGCompatibilityFlag)

    if nargin<1
        PCGCompatibilityFlag=true;
    end

    persistent allowedBlkTypes;
    persistent prohibitedBlkTypes;

    if isempty(allowedBlkTypes)
        [allowedBlkTypes,prohibitedBlkTypes]=Advisor.Utils.Simulink.block.getBlockTypeListFromLibrary('simulink');
        allowedBlkTypes=unique(allowedBlkTypes);
        prohibitedBlkTypes=unique(prohibitedBlkTypes);
        allowedBlkTypes=Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(allowedBlkTypes);
        prohibitedBlkTypes=Advisor.Utils.Simulink.block.convertcell_into_BlkTypeList(prohibitedBlkTypes);
    end

    if PCGCompatibilityFlag
        output=allowedBlkTypes;
    else
        output=prohibitedBlkTypes;
    end

end
