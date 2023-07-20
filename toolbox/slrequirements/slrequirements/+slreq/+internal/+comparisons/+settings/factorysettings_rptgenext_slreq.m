function factorysettings_rptgenext_slreq







    tree=createTree();



    upgraders=createUpgraders();

    resourcesFolder=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','resources');

    matlab.settings.internal.registerFactoryFile(resourcesFolder,tree,upgraders,false);
end

function slreq=createTree()

    slreq=matlab.settings.FactoryGroup.createToolboxGroup("slreq");


    highlight=slreq.addGroup("highlight");
    highlight.addSetting("AlwaysHighlight",...
    "FactoryValue",true,...
    "ValidationFcn",@matlab.settings.mustBeLogicalScalar);
end

function upgraders=createUpgraders()



    upgraders=matlab.settings.SettingsFileUpgrader("v1");
end

