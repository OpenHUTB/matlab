function updateactions(h,inpaction,arractions)







    if(DeploymentDiagram.isTaskConfigurationInUse(h.getRoot))
        return;
    end

    action='on';
    if strcmp(inpaction,'on')==1
        action='off';
    end

    h.setallactions(action);

    for idx=1:length(arractions)
        h.getaction(arractions{idx}).Enabled=inpaction;
    end

    drawnow;
