function highlightBlock(node)














    if isa(node,'simscape.logging.Node')
        model=Simulink.ID.getModel(node.getSource());
        if bdIsLoaded(model)
            pm.sli.highlightSystem(node.getSource());
        else
            pm_error('physmod:common:logging:sli:kernel:ModelNotLoaded',model);
        end
    else
        pm_error('physmod:common:logging:sli:kernel:WrongDataType');
    end

end

