function togglePhasor(command,modelName)





    if~exist('modelName','var')
        modelName=bdroot;
    end



    solverConfiguration=find_system(modelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','MaskType',sprintf('Solver\nConfiguration'));
    if length(solverConfiguration)~=1
        error('Multiple solver configuration blocks found.');
    end
    solverConfiguration=solverConfiguration{1};

    if~exist('command','var')
        equationFormulation=get_param(solverConfiguration,'EquationFormulation');
        switch equationFormulation
        case 'NE_TIME_EF'
            command='on';
        case 'NE_FREQUENCY_TIME_EF'
            command='off';
        otherwise
            error('Unknown solver configuration equation formulation found.');
        end
    end

    switch command
    case 'on'
        set_param(solverConfiguration,'EquationFormulation','NE_FREQUENCY_TIME_EF');
        disp('Phasor mode is on.');
    case 'off'
        set_param(solverConfiguration,'EquationFormulation','NE_TIME_EF')
        disp('Phasor mode is off.');
    end
end

