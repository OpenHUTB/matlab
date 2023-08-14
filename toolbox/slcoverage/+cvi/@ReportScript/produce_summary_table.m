




function produce_summary_table(this,dataEntry,summaryTemplates,options,noComplex)


    isTop=isfield(dataEntry,'sysNum')&&(dataEntry.sysNum==1);
    if isTop

        metricNames=[this.cvstruct.enabledMetricNames,this.cvstruct.enabledTOMetricNames];
    else

        metricNames=[this.metricNames,this.toMetricNames];
    end

    if noComplex
        template=summaryTemplates.mainTemplateNoComplexity;
    else
        template=summaryTemplates.mainTemplate;
    end

    for i=1:length(metricNames)
        thisMetric=metricNames{i};
        if isTop||(isfield(dataEntry,thisMetric)&&~isempty(dataEntry.(thisMetric)))
            template=[template,summaryTemplates.(thisMetric)];%#ok<AGROW>
        end
    end
    tableInfo.cols.align='"left"';
    tableInfo.cols.width=200;
    tableInfo.imageDir=options.imageSubDirectory;
    tableStr=cvprivate('html_table',dataEntry,template,tableInfo);
    printIt(this,'%s',tableStr);

