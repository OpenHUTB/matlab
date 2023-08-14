function datadict_vardelete(filename,varname,entryKeyTxt,report_id)






    realFilename=urldecode(filename);

    try
        dsa=Simulink.dd.DataSourceAccessor(realFilename,'-writable');
        entries=dsa.entries;
        entryKey=Simulink.dd.DataSourceEntryKey.fromString(entryKeyTxt);
        ddEntryInfo=entries.find(entryKey);

        entries.remove(ddEntryInfo);
    catch err

        if nargin>3&&~isempty(report_id)
            c=com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison(report_id);
            if~isempty(c)
                c.doErrorDialog(err.message);
                return;
            end
        else
            error(err.message);
        end
        return;
    end

    if nargin>3&&~isempty(report_id)
        c=com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison(report_id);
        if~isempty(c)


            entries='';
            dsa='';

            c.doRefresh;
        end
    end

end