function cmd=sim(model,cmd)





    if strcmpi(cmd,'update')
        simStatus=get_param(model,'SimulationStatus');
        if~strcmpi(simStatus,'stopped')
            return;
        end
    end

    if strcmpi(cmd,'update')







        try
            pm.sli.updateDiagram(model);
        catch ME
            if(strcmp(ME.identifier,'physmod:pm_sli:sli:model:ModelNotOpen'))
                set_param(model,'SimulationCommand','update');
            else
                rethrow(ME);
            end
        end
    else

        set_param(model,'SimulationCommand',cmd);
    end

end
