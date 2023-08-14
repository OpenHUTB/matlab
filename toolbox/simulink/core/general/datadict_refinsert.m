function datadict_refinsert(destFilename,srcFilename,refname,refKeyTxt,report_id)






    realdestFilename=urldecode(destFilename);
    realSrcFilename=urldecode(srcFilename);

    try
        dsSrc=Simulink.dd.DataSourceAccessor(realSrcFilename);
        dsRefs=dsSrc.dictionaryReferences;
        srcRefKey=Simulink.dd.DictionaryReferenceKey.fromString(refKeyTxt);
        ddReference=dsRefs.find(srcRefKey);

        dsDest=Simulink.dd.DataSourceAccessor(realdestFilename,'-writable');
        dsRefs=dsDest.dictionaryReferences;
        dsRefs.insert(ddReference);

    catch err

        if nargin>4&&~isempty(report_id)
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

    if nargin>4&&~isempty(report_id)
        c=com.mathworks.toolbox.simulink.datadictionary.comparisons.compare.concr.DataDictComparison.getComparison(report_id);
        if~isempty(c)


            dsRefs='';
            dsDest='';
            dsSrc='';

            c.doRefresh;
        end
    end

end
