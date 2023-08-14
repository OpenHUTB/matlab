function openObjectEditor(model,objName)




    [location,~]=slprivate('getVariableLocation',model,objName,model);
    [location,~,fileName,~,~]=slprivate('parseLocation',model,location,objName);
    slprivate('showWorkspaceVar',location,objName,fileName);
end
