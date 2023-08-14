function launchExternalFileEditor(path)


    [~,~,ext]=fileparts(path);


    if strcmpi(ext,'.mat')
        signalEditor('DataSource',path);
    elseif any(strcmpi(ext,[xls.internal.WriteTable.SpreadsheetExts,".csv"]))

        if ispc
            winopen(path)
        else
            error(message('stm:general:MSExcelOnlyOnWindows'));
        end
    else

        Simulink.sdi.Instance.open;


        existingRunIDs=Simulink.sdi.getAllRunIDs;
        existingRunIDs=num2cell(existingRunIDs);
        Simulink.sdi.internal.moveRunsToArchive(existingRunIDs{:});

        Simulink.sdi.load(path);


        runIDs=Simulink.sdi.getAllRunIDs;
        newRuns=num2cell(runIDs(length(existingRunIDs)+1:end));
        Simulink.sdi.internal.moveRunsToStableArea(newRuns{:});
    end
end