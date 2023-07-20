function tt=InstructionSetExtensions_TT(cs,~)



    if isa(cs,'Simulink.ConfigSet')
        hSrc=cs.getComponent('Code Generation').getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        hSrc=cs.getComponent('Target');
    else
        hSrc=cs;
    end

    if isempty(hSrc.InstructionSetExtensions)
        loadedInstructionSets={};
    else
        selected=hSrc.InstructionSetExtensions{1};


        loadedInstructionSets=RTW.getAllRequiredInstructionSets(selected);
    end

    if isempty(loadedInstructionSets)
        tt=message('Coder:configSet:hardwareInstructionSetExtensionsDisabled_Tooltip').getString;
    else
        tt=message('Coder:configSet:hardwareInstructionSetExtensions_Tooltip').getString;
        for i=1:length(loadedInstructionSets)
            tt=sprintf([tt,'\n']);
            tt=sprintf([tt,loadedInstructionSets{i}]);
        end

    end

end

