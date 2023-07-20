function variantGroup=addSIDToVariantGroup(~,variantGroup)
    if strcmp(get_param(variantGroup.NonExpandedBlockPath,'BlockType'),'SubSystem')
        numVariantsInGroup=variantGroup.NumExpandedBlocks;
        if numVariantsInGroup==1
            variantGroup.ExpandedBlock.ChoiceBlockSID=Simulink.ID.getSID(variantGroup.ExpandedBlock.ChoiceBlockPath);
        else
            for gv=1:numVariantsInGroup

                try
                    get_param(variantGroup.ExpandedBlock{gv}.ChoiceBlockPath,'Object');
                catch







                    continue;
                end

                variantGroup.ExpandedBlock{gv}.ChoiceBlockSID=Simulink.ID.getSID(variantGroup.ExpandedBlock{gv}.ChoiceBlockPath);

            end
        end
    end
end
