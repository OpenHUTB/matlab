function optimizeSettingsRefresher(userdata,cbinfo,action)


    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(appContext)
        action.enabled=false;
        return;
    end


    action.enabled=appContext.SimulationProfilingModeEnabled;
    if~action.enabled
        action.dropDownAlwaysEnabled=false;
        return;
    end

    action.dropDownAlwaysEnabled=true;

    modelH=cbinfo.model.Handle;
    compilerOptVal=get_param(modelH,'SimCompilerOptimization');
    ctrlCVal=get_param(modelH,'SimCtrlC');
    overflowVal=get_param(modelH,'IntegerOverflowMsg');
    satuationOptVal=get_param(modelH,'IntegerSaturationMsg');

    compilerOptOptimal=strcmpi(compilerOptVal,'on');
    ctrlCOptimal=strcmpi(ctrlCVal,'off');
    overflowOptimal=strcmpi(overflowVal,'none');
    satuationOptimal=strcmpi(satuationOptVal,'none');

    switch(userdata)
    case 'all'
        action.enabled=~(compilerOptOptimal&&ctrlCOptimal&&overflowOptimal&&satuationOptimal);
    case 'compilerOpt'
        action.selected=compilerOptOptimal;
    case 'ctrlC'
        action.selected=ctrlCOptimal;
    case 'overflow'
        action.selected=overflowOptimal;
    case 'saturate'
        action.selected=satuationOptimal;
    end

end
