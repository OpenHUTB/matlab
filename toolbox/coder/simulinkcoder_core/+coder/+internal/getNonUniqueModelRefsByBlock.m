function[names,modes,codeInterface,nameDialogs,blocks]=getNonUniqueModelRefsByBlock(iBlocks,isCodeVariants)





    if isCodeVariants
        nameDialogsByBlock=get_param(iBlocks,'CodeVariantModelNameDialogs');
        namesByBlock=get_param(iBlocks,'CodeVariantModelNames');
        modesByBlock=get_param(iBlocks,'CodeVariantSimulationModes');




        codeInterfaceByBlock=cell(numel(iBlocks),1);
        blocksByBlock=cell(numel(iBlocks),1);
        for kBlk=1:numel(iBlocks)
            nVariantsForThisBlock=numel(namesByBlock{kBlk});
            codeInterfaceByBlock{kBlk}=repmat({get_param(iBlocks{kBlk},'CodeInterface')},1,nVariantsForThisBlock);
            blocksByBlock{kBlk}=repmat({iBlocks{kBlk}},1,nVariantsForThisBlock);
        end
    else
        nameDialogsByBlock={get_param(iBlocks,'ModelNameDialog')};
        namesByBlock={get_param(iBlocks,'ModelNameInternal')};
        modesByBlock={get_param(iBlocks,'SimulationMode')};
        codeInterfaceByBlock={get_param(iBlocks,'CodeInterface')};
        blocksByBlock={iBlocks};
    end

    nameDialogs=[nameDialogsByBlock{:}]';
    names=[namesByBlock{:}]';
    modes=[modesByBlock{:}]';
    codeInterface=[codeInterfaceByBlock{:}]';
    blocks=[blocksByBlock{:}]';
end
