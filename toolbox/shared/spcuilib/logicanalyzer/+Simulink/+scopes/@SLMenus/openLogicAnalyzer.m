function schema=openLogicAnalyzer(cbinfo,varargin)




    schema=sl_action_schema;
    schema.tag='Simulink:OpenLogicAnalyzer';

    if Simulink.scopes.LAScope.isLogicAnalyzerAvailable()
        schema.state=Simulink.scopes.SLMenus.getLogicAnalyzerState(cbinfo);
    else

        schema.state='Hidden';
        return;
    end

    schema.callback=@openLogicAnalyzer_CB;
    schema.autoDisableWhen='Never';
    schema.refreshCategories={'interval#4','SimulinkEvent:Simulation'};


    newData=Simulink.scopes.LAScope.isNewDataAvailable(cbinfo.model.Name);
    schema.label='simulink_ui:studio:resources:openLogicAnalyzerActionLabel';

    if newData
        schema.icon='resultLogicAnalyzerActive';
    else
        schema.icon='logicAnalyzerApp';
    end

end


function openLogicAnalyzer_CB(cbinfo)

    modelName=cbinfo.editorModel.Name;


    set_param(0,'LastVisualizer','LogicAnalyzer');

    laScope=Simulink.scopes.LAScope.getLogicAnalyzer(modelName);
    laScope.IsNewDataAvailable=false;

    Simulink.scopes.LAScope.openLogicAnalyzer(modelName);

end
