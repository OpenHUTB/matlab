
function generateDetailedReport(rpts,fileName,modelcovId,cvhtmlSettings,simMode)








    try

        rpts.waitbarH=cvi.ReportScript.createCovWaitBar(cvhtmlSettings,rpts.titleModelName);

        [path,name,ext]=cvi.ReportUtils.getFilePartsWithWriteChecks(fileName,'.html');
        baseFileName=fullfile(path,append(name,ext));

        [copyImages,htmlData]=dump_html(baseFileName,rpts,cvhtmlSettings,simMode);

        if copyImages
            cvi.ReportUtils.prepareImageFiles(path);
        end

        if cvhtmlSettings.showReport&&~cvhtmlSettings.mathWorksTesting
            hBrowser=cvprivate('local_browser_mgr','displayFile',baseFileName);
            if~isempty(hBrowser)

                cvprivate('html_info_mgr','load',baseFileName,htmlData);



                cv('set',modelcovId,'modelcov.currentDisplay.browserWindow',hBrowser);
            else
                warning(message('Slvnv:simcoverage:cvhtml:UnableToOpenCoverageReport'));
            end
            cv('set',modelcovId,'modelcov.currentDisplay.baseReportName',baseFileName);
        else


            cvprivate('html_info_mgr','load',baseFileName,htmlData);
        end

        clean_up(rpts);
    catch Mex
        clean_up(rpts);
        rethrow(Mex);
    end


    function clean_up(this)
        if~isempty(this)
            if~isempty(this.waitbarH)
                delete(this.waitbarH);
            end
        end






        function[copyImages,htmlData]=dump_html(baseFileName,this,options,simMode)


            htmlData=[];
            isSigCoverage=this.isSigCoverage;


            testIds=[this.allTests{:}];

            if numel(this.allTests)>1&&~options.cumulativeReport
                total=this.allTests{1};
                for i=2:length(this.allTests)
                    total=total+this.allTests{i};
                end
                this.allTests{i+1}=total;
            end

            toReportDetails=~isempty(this.metricNames)||~isempty(this.toMetricNames);
            copyImages=(toReportDetails||isSigCoverage);
            if toReportDetails
                this.cvstruct=cvprivate('report_create_structured_data',this.allTests,testIds,this.metricNames,this.toMetricNames,options,this.waitbarH);
                if options.filtSFEvent
                    this.cvstruct=cvprivate('cvfilter',this.cvstruct,this.metricNames);
                end
            end

            this.openFile(baseFileName);

            this.dumpTitle(this.titleModelName);


            if~options.explorerGeneratedReport
                topReportName=fullfile(this.baseReportDir,append('docked__cov__report__',options.topModelName,'__',simMode,'.html'));
                if isfile(topReportName)&&~strcmp(baseFileName,topReportName)
                    printIt(this,'<a href="file:///%s"> %s</a>\n',topReportName,getString(message('Slvnv:simcoverage:cvhtml:ReturnToTopModelReport')));
                end
            end


            hasAggregatedTestInfo=numel(this.allTests)==1&&...
            ~isempty(this.allTests{1}.aggregatedTestInfo)&&...
            options.aggregatedTests;




            toc={'Slvnv:simcoverage:cvhtml:AnalysisInformation'};
            if hasAggregatedTestInfo
                toc{end+1}='Slvnv:simcoverage:cvhtml:AggregatedTests';
            else
                toc{end+1}='Slvnv:simcoverage:cvhtml:Tests';
            end
            if toReportDetails
                toc{end+1}='Slvnv:simcoverage:cvhtml:Summary';
                toc{end+1}='Slvnv:simcoverage:cvhtml:Details';
            end
            if isSigCoverage
                toc{end+1}='Slvnv:simcoverage:cvhtml:SignalRanges';
            end
            generate_table_of_contents(this,toc);



            if~isempty(options.reportSubTitle)
                printIt(this,options.reportSubTitle);
            end


            dumpAnalysisInformation(this,this.allTests{1},options);

            if hasAggregatedTestInfo
                this.cvstruct.testLabels={''};
                this.dumpAggregatedTestSummary(this.allTests{1},options);
            else
                this.cvstruct.testLabels=dumpTestSummary(this,this.allTests,options);
            end


            if toReportDetails||isSigCoverage

                if toReportDetails
                    dumpStructuralCoverage(this,options);
                end

                if isSigCoverage
                    topCvId=cv('get',this.allTests{1}.rootId,'.topSlsf');
                    dumpModelSignalRange(this,topCvId,this.allTests,this.waitbarH,options);
                end
            else
                printIt(this,'<h3>%s</h3>\n',getString(message('Slvnv:simcoverage:cvhtml:ThereIsNoReport')));
            end

            printIt(this,'</body>\n');

            if~isempty(this.tableDataCache)
                htmlData.lookupTableInfo=this.tableDataCache;
                add_persistent_data_to_html(this,htmlData);
            end

            printIt(this,'</html>\n');

            closeFile(this)

