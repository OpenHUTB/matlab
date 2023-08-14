




function modifiedVCForaBlock=i_handleSpecialCasesInVCForaBlock(VCInfoForaBlock)

    modifiedVCForaBlock=cellfun(@strtrim,VCInfoForaBlock,'UniformOutput',false);

    commentedIndices=cellfun(@(X)(~isempty(X)&&X(1)=='%'),modifiedVCForaBlock);
    modifiedVCForaBlock=modifiedVCForaBlock(~commentedIndices);

    ignoredIndices=cellfun(@(X)(isempty(X)),modifiedVCForaBlock);
    modifiedVCForaBlock=modifiedVCForaBlock(~ignoredIndices);

    defaultIndices=strcmp(modifiedVCForaBlock,'(default)');
    nonDefaultModifiedVCForaBlock=modifiedVCForaBlock(~defaultIndices);

    if((nnz(defaultIndices)>1)||isempty(nonDefaultModifiedVCForaBlock))
        error('Validation issue to be caught later');
    end


    if any(defaultIndices)
        defaultCondition=['~((',strjoin(nonDefaultModifiedVCForaBlock,') || ('),'))'];
        modifiedVCForaBlock{defaultIndices}=defaultCondition;
    end
end
