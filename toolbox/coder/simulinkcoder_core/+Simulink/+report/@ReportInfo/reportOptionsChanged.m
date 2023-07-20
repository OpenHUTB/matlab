function out=reportOptionsChanged(obj)
    currentConfig=Simulink.report.Config(obj.getActiveModelName);


    out=true;

    if~isempty(obj.Config)
        currentConfig.LaunchReport=obj.Config.LaunchReport;
        out=~isequal(currentConfig,obj.Config);
    end
end
