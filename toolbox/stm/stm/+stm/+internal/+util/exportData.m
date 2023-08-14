function retMSG=exportData(runIDs,signalIDs,activeApp)





    varName='';

    if~isempty(runIDs)
        if strcmpi(activeApp,'Comparison')
            varName='slt_exported_comparison_run';
        else
            varName='slt_exported_run';
        end
    elseif~isempty(signalIDs)
        if strcmpi(activeApp,'Comparison')
            varName='slt_exported_comparison_signals';
        else
            varName='slt_exported_signals';
        end
    end

    engine=Simulink.sdi.Instance.engine;

    engine.exportToBaseWorkspace(runIDs,signalIDs,activeApp,varName);

    retMSG=getString(message('stm:ResultsTree:ExportDataSuccess',varName));
end