

function modelDesignDashboard(cbInfo)
    bdname=cbInfo.editorModel.Name;


    bdFile=get_param(bdname,'FileName');

    if isempty(bdFile)
        error(message('dashboard:metricsdashboard:UnsavedModel',bdname));
    end

    dashboard.internal.openDashboard(dashboard.internal.LayoutConstants.ModelMaintainability,...
    bdFile,bdname,true);
end