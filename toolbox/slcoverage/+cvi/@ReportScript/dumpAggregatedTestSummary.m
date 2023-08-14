function res=dumpAggregatedTestSummary(this,cvd,options)




    res=false;
    ati=cvd.aggregatedTestInfo;
    if isempty(ati)
        return;
    end
    addDescription(this,cvd,options);
    msgId='Slvnv:simcoverage:cvhtml:AggregatedTests';
    htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
    printIt(this,'<a name="%s"></a><h3>%s</h3>\n',htmlTag,getString(message(msgId)));

    [tableData,colSettings]=buildReportStruct(cvd.aggInfoMap,options);
    [tableInfo,tableTemplate]=getTemplate(options,colSettings);
    tableStr=cvprivate('html_table',tableData,tableTemplate,tableInfo);
    printIt(this,'%s',tableStr);
    printIt(this,'<br/>\n');

    res=true;
end

function addDescription(this,cvd,options)
    descr=cvd.description;
    if~isempty(descr)
        msgId='Slvnv:simcoverage:cvhtml:AggregatedTestsDescription';
        htmlTag=cvi.ReportScript.convertNameToHtmlTag(msgId);
        printIt(this,'<a name="%s"></a><h3>%s</h3>\n',htmlTag,getString(message(msgId)));
        printIt(this,'<table border="0"> <tr>\n');
        descr=cvi.ReportUtils.addCSSRule(descr,'p.descr');
        printIt(this,[' <td>',descr,'</td>']);
        printIt(this,'</tr>\n</table>');
    end

end


function[tableData,colSettings]=buildReportStruct(aggInfoMap,options)

    colSettings.hasModelNameTitle=false;
    colSettings.hasTestCaseName=false;
    colSettings.hasDescription=false;

    tableData=[];
    allKeys=aggInfoMap.keys();
    for idxA=1:numel(allKeys)
        modelName=allKeys{idxA};
        aggInfo=aggInfoMap(modelName);
        if contains(modelName,'/')
            modelName=sprintf('<a name="%s"></a><b>%s: "%s"</b>','TBD',getString(message('Slvnv:simcoverage:cvhtml:Subsystem')),modelName);
        else
            modelName=sprintf('<a name="%s"></a><b>%s: "%s"</b>','TBD',getString(message('Slvnv:simcoverage:cvhtml:Model')),modelName);
        end
        tmpTableData.modelName=modelName;

        traceData=[];
        for idx=1:numel(aggInfo)
            cagi=aggInfo(idx);

            traceLabel=cagi.traceLabel;
            td.runId=sprintf('<a name="ref_trace_%s">%s</a>',traceLabel,traceLabel);
            testCaseName=cvi.ReportScript.getTestCaseName(cagi.testRunInfo,options);
            if~isempty(testCaseName)
                td.testCaseName=testCaseName;
                colSettings.hasTestCaseName=true;
            else
                td.testCaseName='N/A';
            end
            if~isempty(cagi.description)
                colSettings.hasDescription=true;
            end
            td.description=cagi.description;

            if isempty(td.description)
                td.description=' ';
            end
            td.date=cagi.date;
            if isempty(traceData)
                traceData=td;
            else
                traceData=[traceData,td];%#ok<AGROW>
            end
        end
        tmpTableData.traceData=traceData;
        if isempty(tableData)
            tableData=tmpTableData;
        else
            tableData=[tableData,tmpTableData];%#ok<AGROW>
        end
    end
end

function[tableInfo,tableTemplate]=getTemplate(options,colSettings)

    tableInfo.table='border="1" cellpadding="5" ';
    tableInfo.cols=struct('align','"left"');
    tableInfo.imageDir=options.imageSubDirectory;

    numOfCol=2;
    tableTitle={['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:Run')),' </b>']};
    tableRows={{'Cat','#runId'}};
    if colSettings.hasTestCaseName
        tableTitle=[tableTitle,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:TestName')),' </b>']}];
        tableRows=[tableRows,{{'Cat','#testCaseName'}}];
        numOfCol=numOfCol+1;
    end
    if colSettings.hasDescription
        tableTitle=[tableTitle,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:Description')),' </b>']}];
        tableRows=[tableRows,{{'Cat','#description'}}];
        numOfCol=numOfCol+1;
    end

    tableTitle=[tableTitle,{['$<b> ',getString(message('Slvnv:simcoverage:cvhtml:Date')),' </b>']}];
    tableRows=[tableRows,{{'Cat','#date'}}];

    tableTemplate=...
    {...
    tableTitle{:},...
'\n'...
    ,{'ForEach','#.',...
    {'CellFormat',{'Cat','$<b>','#modelName','$</b>'},numOfCol},...
'\n'...
    ,{'ForEach','#traceData',...
    tableRows{:},...
    '\n',...
    }...
    }...
    };%#ok<CCAT>
end