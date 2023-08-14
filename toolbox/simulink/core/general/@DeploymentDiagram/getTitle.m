function title=getTitle(h)





    if isa(h,'DAStudio.DAObjectProxy')
        h=h.getMCOSObjectReference;
    end

    if DeploymentDiagram.isConcurrentTasks(h.ParentDiagram)
        activeStr=DAStudio.message('RTW:configSet:titleStrActive');
    else
        activeStr=DAStudio.message('RTW:configSet:titleStrInactive');
    end

    title=[DAStudio.message('Simulink:mds:ConfigComponentName'),...
    ': ',...
    h.ParentDiagram,...
    ' ',...
    activeStr];

