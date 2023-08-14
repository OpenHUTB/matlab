function cvhtml_cvdatagroup(fileName,varargin)


    obj=cvi.ReportScriptTopSummary(fileName,varargin);

    if obj.options.summaryMode>0
        obj.generateString=true;
        obj.run;
        if obj.options.summaryMode==2
            rpt=cvi.ReportGen.ReportGen(obj);
            rpt.run;
        else
            obj.options.summaryHtml=obj.htmlStr;
        end
    else
        obj.run;
    end
