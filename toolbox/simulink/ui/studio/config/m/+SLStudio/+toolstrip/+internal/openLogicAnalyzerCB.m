function openLogicAnalyzerCB(cbinfo)
    model=cbinfo.model.Name;
    modelName=get_param(model,'name');


    set_param(0,'LastVisualizer','LogicAnalyzer');

    laScope=Simulink.scopes.LAScope.getLogicAnalyzer(modelName);
    laScope.IsNewDataAvailable=false;

    Simulink.scopes.LAScope.openLogicAnalyzer(modelName);
end
