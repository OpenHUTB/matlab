function closeHarnessDialogs(model)


    allDialogs=DAStudio.ToolRoot.getOpenDialogs()';
    n=length(allDialogs);
    for i=1:n
        if strcmp(allDialogs(i).dialogTag,'UpdateSimulationHarnessDialog')
            src=allDialogs(i).getSource();
            if strcmp(src.harness.model,model)
                delete(allDialogs(i));
            end
        elseif strcmp(allDialogs(i).dialogTag,'CreateSimulationHarnessDialog')||...
            strcmp(allDialogs(i).dialogTag,'HarnessImportDlgTag')
            src=allDialogs(i).getSource();
            if strcmp(get_param(bdroot(src.harnessOwner.handle),'Name'),model)
                delete(allDialogs(i));
            end
        end
    end
end
