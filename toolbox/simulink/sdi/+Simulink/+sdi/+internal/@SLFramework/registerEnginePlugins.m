function registerEnginePlugins(this,eng,isMainEng)





    mfw=Simulink.sdi.internal.MLFramework;
    mfw.registerEnginePlugins(eng,isMainEng);


    persistent is_init
    if isempty(is_init)||~isMainEng

        wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
        wksParser.registerVariableParser(...
        'Simulink.sdi.internal.import.SimulinkTimeseriesParser');
        wksParser.registerVariableParser(...
        'Simulink.sdi.internal.import.ModelDataLogsParser');


        exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
        if exist('slTestResult','class')==8
            exporter.registerVariableExporter(...
            'sltest.internal.sdi.AssessmentExporter');
        end
    end


    if isMainEng&&~isempty(eng)
        is_init=true;
        Simulink.sdi.internal.registerMetaDataUpdates(eng);

        if isempty(this.Listeners)
            this.Listeners=event.listener(eng,'clearSDIEvent',@locOnSDIClear);
        end
    end

end


function locOnSDIClear(~,~)
    Simulink.sdi.internal.SLMenus.getSetNewDataAvailable('',false);
end
