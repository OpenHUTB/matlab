function isSimulating=is_simulating_l(UD)




    isSimulating=false;

    if isstruct(UD)&&isfield(UD,'simulink')&&isfield(UD.simulink,'modelH'),
        if~strcmp(get_param(UD.simulink.modelH,'simulationStatus'),'stopped')&&get_param(UD.simulink.modelH,'InteractiveSimInterfaceExecutionStatus')~=2
            isSimulating=true;
        end;
    end;