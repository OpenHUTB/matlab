



function layout=getDashboardLayout(prjFolder,appID,layoutID,layoutClassName)

    uiConfig=dashboard.internal.UiConfiguration();

    configFile=uiConfig.getLayoutConfigFile(prjFolder,appID);

    [configLocation,configFileName]=fileparts(configFile);

    openConfigFcn=str2func(sprintf('%s.open',layoutClassName));

    config=openConfigFcn('FileName',configFileName,'Location',configLocation);

    if isempty(layoutID)||(isstring(layoutID)&&layoutID=="")
        layout=config.Layouts(1);
    else
        layout=config.getLayout(layoutID);
        if isempty(layout)
            ids=sprintf('"%s", ',config.Layouts.Id);
            error(message('dashboard:uidatamodel:InvalidLayoutID',...
            layoutID,appID,ids(1:end-2)));
        end
    end
end