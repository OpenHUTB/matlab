function names=runtimeParameters(model)









    names={};


    names=[names;evalin('base','who')];


    try
        names=[names;evalin('caller','who')];
    catch e

        if~strcmp(e.identifier,'MATLAB:err_transparency_violation')
            rethrow(e);
        end
    end


    ddName=get_param(model,'DataDictionary');
    if~isempty(ddName)
        dd=Simulink.dd.open(ddName);
        ddVars=dd.getChildNames('Global');
        names=[names;ddVars];
    end


    modelWks=get_param(model,'ModelWorkspace');
    try
        names=[names;{modelWks.whos.name}'];
    catch
    end


    siGlobalWks=get_param(model,'SimulationInputGlobalWorkspace');
    try
        names=[names;{siGlobalWks.whos.name}'];
    catch
    end

    siModelWks=get_param(model,'SimulationInputModelWorkspace');
    try
        names=[names;{siModelWks.whos.name}'];
    catch
    end


    names=unique(names);
end
