function datadict_refdelete(filename,refname,refKeyTxt,report_id)






    realdestFilename=urldecode(filename);

    try
        dsDest=Simulink.dd.DataSourceAccessor(realdestFilename,'-writable');

        dsRefs=dsDest.dictionaryReferences;

        refKey=Simulink.dd.DictionaryReferenceKey.fromString(refKeyTxt);
        ddReference=dsRefs.find(refKey);

        dsRefs.remove(ddReference);

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


            dsRefs='';
            dsDest='';

            c.doRefresh;
        end
    end

end