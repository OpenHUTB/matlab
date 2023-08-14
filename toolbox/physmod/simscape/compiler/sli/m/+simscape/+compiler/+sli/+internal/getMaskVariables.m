function maskVars=getMaskVariables(blockPath)










    numMasks=0;
    maskVars={struct('Name',{},'Prompt',{},'Value',{})};

    mask=Simulink.Mask.get(blockPath);
    while~isempty(mask)
        numMasks=numMasks+1;
        maskVars{numMasks}=struct('Name',{mask.Parameters(:).Name},...
        'Prompt',{mask.Parameters(:).Prompt},...
        'Value',{mask.Parameters(:).Value});
        mask=mask.BaseMask;
    end