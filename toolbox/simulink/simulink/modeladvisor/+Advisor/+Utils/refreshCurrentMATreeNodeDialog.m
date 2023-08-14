function refreshCurrentMATreeNodeDialog(maObj)


    if isa(maObj,'Simulink.ModelAdvisor')&&isa(maObj.MAExplorer,'DAStudio.Explorer')
        imme=DAStudio.imExplorer(maObj.MAExplorer);
        dlgs=DAStudio.ToolRoot.getOpenDialogs(Advisor.Utils.convertMCOS(imme.getCurrentTreeNode));
        if isa(dlgs,'DAStudio.Dialog')
            dlgs.restoreFromSchema;
        end
    end
end