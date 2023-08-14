function netCond=createBlockVariantConstraint(varName,equalityValues,inequalityValues,hasDerivedRange,hasTrueChoice)





    if hasTrueChoice

        netCond=Simulink.variant.reducer.fullrange.combineByAND([...
        cellfun(@(X)([varName,' ~= ',num2str(X)]),equalityValues,'UniformOutput',false),...
        cellfun(@(X)([varName,' == ',num2str(X)]),inequalityValues,'UniformOutput',false)]);
    else


        choiceConds=cell(numel(equalityValues)+numel(inequalityValues)+hasDerivedRange,1);


        for i=1:numel(equalityValues)

            choiceConds{i,1}=...
            Simulink.variant.reducer.fullrange.combineByAND([[varName,'==',num2str(equalityValues{i})],...
            cellfun(@(X)([varName,' ~= ',num2str(X)]),equalityValues([1:(i-1),(i+1):end]),'UniformOutput',false),...
            cellfun(@(X)([varName,' == ',num2str(X)]),inequalityValues,'UniformOutput',false)]);
        end


        for i=1:numel(inequalityValues)

            choiceConds{numel(equalityValues)+i,1}=...
            Simulink.variant.reducer.fullrange.combineByAND([[varName,'~=',num2str(inequalityValues{i})],...
            cellfun(@(X)([varName,' == ',num2str(X)]),inequalityValues([1:(i-1),(i+1):end]),'UniformOutput',false),...
            cellfun(@(X)([varName,'~=',num2str(X)]),equalityValues,'UniformOutput',false)]);
        end

        if hasDerivedRange

            choiceConds{numel(equalityValues)+numel(inequalityValues)+1,1}=...
            Simulink.variant.reducer.fullrange.combineByAND([...
            cellfun(@(X)([varName,'~=',num2str(X)]),equalityValues,'UniformOutput',false),...
            cellfun(@(X)([varName,'==',num2str(X)]),inequalityValues,'UniformOutput',false)]);
        end

        netCond=Simulink.variant.reducer.fullrange.combineByOR(choiceConds);
    end


