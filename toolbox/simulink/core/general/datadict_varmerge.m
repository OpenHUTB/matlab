function datadict_varmerge(srcFilename,destFilename,srcVarname,destVarname,srcEntrykeyTxt,destEntrykeyTxt,report_id)






    realdestFilename=urldecode(destFilename);
    realsrcFilename=urldecode(srcFilename);

    try
        dsSrc=Simulink.dd.DataSourceAccessor(realsrcFilename);
        entriesSrc=dsSrc.entries;
        srcEntryKey=Simulink.dd.DataSourceEntryKey.fromString(srcEntrykeyTxt);
        ddSrcEntryInfo=entriesSrc.find(srcEntryKey);

        dsDest=Simulink.dd.DataSourceAccessor(realdestFilename,'-writable');
        entriesDest=dsDest.entries;
        if isempty(destEntrykeyTxt)
            entriesDest.insert(ddSrcEntryInfo);
            entriesDest.first;
        else
            destEntryKey=Simulink.dd.DataSourceEntryKey.fromString(destEntrykeyTxt);
            ddDestEntryInfo=entriesDest.find(destEntryKey);

            if isequal(srcEntrykeyTxt,destEntrykeyTxt)
                entriesDest.update(ddSrcEntryInfo);
            else


                entriesDest.remove(ddDestEntryInfo);
                entriesDest.insert(ddSrcEntryInfo);
            end
        end
    catch err

        if nargin>6&&~isempty(report_id)
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

    if nargin>6&&~isempty(report_id)
        c=com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison(report_id);
        if~isempty(c)


            clear entriesDest;
            clear dsDest;
            clear entriesSrc;
            clear dsSrc;

            c.doRefresh;
        end
    end

end
