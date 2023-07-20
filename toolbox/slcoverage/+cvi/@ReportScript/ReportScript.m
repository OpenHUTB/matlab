



classdef ReportScript<cvi.ReportScriptBase
    properties
        metricNames=[]
        toMetricNames=[]
        sigMetricNames=[]
        isSigCoverage=[]
        allTests=[]
        waitbarH=[]
        cvstruct=[]
        hasDecisionInfo=[]
        hasMcdcInfo=[]
        hasConditionInfo=[]
        hasTableExecInfo=[]
        hasTestobjectiveInfo=[]
        uncovIdArray=[]
        testCnt=[]
        totalIdx=[]
        columnCnt=[]
        sysSummaryScript=[]
        blkSummaryScript=[]
        titleModelName=''
        tableDataCache=[]
        filterFileName=''
        appliedFilters=[]
        rationaleMap=[]
    end
    methods(Static=true)
        [sysSummary,blkSummary]=decision_summary(testCnt,options)
        [sysSummary,blkSummary]=decision_summary_script(metricName,totalCol,txtOutcomes,metricSummAbbrev)
        [sysSummary,blkSummary]=condition_summary(testCnt,options)
        [sysSummary,blkSummary]=mcdc_summary(testCnt,options)


        [sysSummary,blkSummary]=tableExec_summary(testCnt,options)
        [sysSummary,blkSummary]=testobjective_summary(testCnt,metricName,options)
        [fileNames,cntThresh]=prepare_table_mapping_output(execCounts,options,varargin)
        titleStr=object_titleStr_and_link(idPos,addtxt,commandType,isLinked)
        [isReqTable,titleStr]=getDescriptionStrAndLinkIfReqTable(sfId)
        decData=collapse_text(decData)
        info=getReducedBlocksInfo(testId)
        [t1,t2]=getElimantedBlocksTemplate(options)
        info=getFilteredBlocks(this,options,topSlsf,includeDescendants)
        insertInformerText(infrmObj,blkEntry,htmlStr)
        htmlTag=convertNameToHtmlTag(name);
        [min,max]=convertNonEvaluatedSigRangesToNan(min,max)
        generate_table(options,varargin)
        htmlStr=make_table_map_legend(fileNames,brkValues,varargin)
        testCaseName=getTestCaseName(testRunInfo,options)
        waitbarH=createCovWaitBar(cvhtmlSettings,itemName)

    end
    methods

        function this=ReportScript(allTests,cvhtmlSettings,titleModelName)
            [metricN,toMetricNames]=cvi.ReportUtils.get_common_metric_names(allTests);

            sigMetricNames={'sigrange','sigsize'};
            this.isSigCoverage=cvhtmlSettings.reportSignalRange&&~isempty(intersect(sigMetricNames,metricN));
            this.metricNames=setdiff(metricN,sigMetricNames);
            if cvhtmlSettings.filtExecMetric
                toMetricNames=setdiff(toMetricNames,'cvmetric_Structural_block');
            end
            this.toMetricNames=toMetricNames;
            this.allTests=allTests;
            this.titleModelName=titleModelName;
        end

        add_persistent_data_to_html(this,htmlData)
        produce_navigation_table(this,nodeEntry,uncovIdArray,options)
        testLabels=dumpTestSummary(this,allTests,options)
        res=dumpAggregatedTestSummary(this,allTests,options)
        res=dumpFilteredBlocksInfo(this,filterInfo,options)
        dumpFilteredAndReducedBlocksInfo(this,testId,options,label)
        dumpAnalysisInformation(this,dataId,options)
        linkStr=getTraceLink(this,tags,isIncidental,options)
        testobjective_details(this,blkEntry,cvstruct,metricName,options,testobjectiveIdx)
        decision_details(this,blkEntry,cvstruct,options,decIdx)
        decision_details_script(this,decData,decIdx,totalCol,options,metricDesc)
        condition_details(this,blkEntry,cvstruct,options,condIdx)
        mcdc_details(this,blkEntry,cvstruct,options,mcdcIdx)
        tableExec_details(this,blkEntry,cvstruct,options)
        dumpModelSignalRange(this,cvId,allTests,waitbarH,options)
        initHasMetricFlags(this,options)
        dumpStructuralCoverage(this,options)
        dumpSummary(this,options)
        dumpBlockFilteringTable(this,blkEntry,options)
        dumpRequirementTable(this,blkEntry,options);
        dumpExecutedIn(this,blkEntry,options)
        dumpShortSummary(this,shortSummBlocks,options)
        dumpDetails(this,options)
        dumpSubsystemSummary(this,sysEntry,i,true,options)
        dumpSubsystemDetails(this,sysEntry,inReport,options)
        shortSummBlocks=dumpBlockDetails(this,shortSummBlocks,blkEntry,needTitle,options)
        dump_eml(this,emlBlkEntry,inReport,options)
        produce_summary_table(this,outFile,dataEntry,summaryTemplates,options,noComplex)
        [res,summ,resMetricNames]=isShortSummary(this,dataEntry,options)
        getTemplates(this,options)
        reportMetricDetails(this,sysEntry,inReport,options)
        res=chekcHasOnlyBlockCoverageMetric(this,blkEntry)
        generateDetailedReport(rpts,fileName,modelcovId,cvhtmlSettings,covMode)
        generateSummary(rpts,cvhtmlSettings)
        htmlStr=generateBlock(this,cvId,options)
        htmlStr=generateSubsystem(this,cvId,options)
        blkEntriesSorted=sortBlocksCustomOrder(this,blockIdxs)

        function dumpTitle(this,modelName)
            printIt(this,'<html>\n');
            printIt(this,'<head>\n');
            printIt(this,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>\n');

            printIt(this,'%s\n',cvi.ReportUtils.getJScriptSection());
            printIt(this,'%s\n',cvi.ReportUtils.getCSSSection);
            printIt(this,'<title> %s </title>\n',getString(message('Slvnv:simcoverage:cvhtml:CoverageReport',modelName)));
            printIt(this,'</head>\n');
            printIt(this,'\n');
            printIt(this,'<body>\n');
            printIt(this,'<h1>%s</h1>\n',getString(message('Slvnv:simcoverage:cvhtml:CoverageReportFor',modelName)));
        end

        function generate_table_of_contents(this,toc)
            printIt(this,'<a name="%s"></a><h2>%s</h2>\n',cvi.ReportScript.convertNameToHtmlTag('Slvnv:simcoverage:cvhtml:TableOfContents'),getString(message('Slvnv:simcoverage:cvhtml:TableOfContents')));
            printIt(this,'<ol>\n');
            for idx=1:length(toc)
                htmlTag=cvi.ReportScript.convertNameToHtmlTag(toc{idx});
                printIt(this,'\t<li><a href="#%s">%s</a></li>\n',htmlTag,getString(message(toc{idx})));
            end
            printIt(this,'</ol>\n');
        end
    end
end
