function updateConfig(obj)
    obj.Config=Simulink.report.Config(get_param(obj.getActiveModelName,'handle'));
end
