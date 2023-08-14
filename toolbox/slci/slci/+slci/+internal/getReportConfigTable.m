

function table=getReportConfigTable(tableName)

    persistent rconfig;
    if isempty(rconfig)
        rconfig=slci.internal.ReportConfig;
    end

    table=rconfig.(tableName);
end