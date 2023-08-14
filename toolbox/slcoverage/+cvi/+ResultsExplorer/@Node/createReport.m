function createReport(obj)




    try
        resultsExplorer=obj.parentTree.resultsExplorer;

        [options,changeInOptions]=resultsExplorer.getOptions;

        if~isempty(obj.data.lastReport)&&...
            ~options.generateWebViewReport&&...
            exist(obj.data.lastReport,'file')&&...
            ~changeInOptions
            web(obj.data.lastReport,'-new');
            return;
        end
        outputDir=cvi.TopModelCov.checkOutputDir(options.covOutputDir);
        if isempty(outputDir)
            return;
        end

        data=obj.data;
        cvd=data.getCvd();

        if obj.isActiveRoot
            obj.applyFilter;
        end

        fileName=[resultsExplorer.topModelName,'_',data.filename];
        if data.isCvdatagroup
            fileName=[fileName,'_summary'];
        end

        fullFileName=cvi.ReportUtils.get_report_file_name(fileName,'fileDir',outputDir);
        oldShowReport=options.showReport;
        options.showReport=true;
        options.explorerGeneratedReport=true;
        if~isempty(resultsExplorer.filterExplorer)
            options.setFilterCtxId(resultsExplorer.uuid,'cvhtml');
        end
        createdReport=true;
        if obj.isCum&&options.covCumulativeReport
            lastChild=obj.parentTree.root.children{end};
            lastNodeCvd=lastChild.data.getCvd();
            children=obj.parentTree.root.children(1:end-1);
            oldCumulativeReport=obj.aggregateData(children,resultsExplorer.topModelName);
            deltaCvd=cvd-oldCumulativeReport;

            res=saveLabels({lastNodeCvd,cvd});
            lastNodeCvd.description=getString(message('Slvnv:simcoverage:cvhtml:CurrentRun'));
            deltaCvd.description=getString(message('Slvnv:simcoverage:cvhtml:Delta'));
            cvd.description=getString(message('Slvnv:simcoverage:cvhtml:Cumulative'));

            oldCumulativeReport=options.cumulativeReport;
            options.cumulativeReport=true;
            allCvd=setFilterDataForCumulativeReport({lastNodeCvd,deltaCvd,cvd});
            cvhtml(fullFileName,allCvd{:},options);
            options.cumulativeReport=oldCumulativeReport;

            restoreLabels(res,{lastNodeCvd,cvd});
        else
            try
                cvhtml(fullFileName,cvd,options);
            catch
                createdReport=false;
                warndlg(getString(message('Slvnv:simcoverage:cvresultsexplorer:ReportErrorDueToModelChange')),...
                getString(message('Slvnv:simcoverage:cvresultsexplorer:GenerateReport')),'modal');
            end

        end
        if createdReport
            options.showReport=oldShowReport;
            data.lastReport=fullFileName;
        end

    catch MEx
        rethrow(MEx);
    end
end

function allCvd=setFilterDataForCumulativeReport(allCvd)
    if numel(allCvd)==1
        return;
    end

    cvds={};
    for idx=1:numel(allCvd)-1
        cvd=allCvd{idx};
        if isa(cvd,'cvdata')
            cvds=[cvds,{cvd}];%#ok<AGROW>
        else
            cvds=[cvds,cvd.getAll];%#ok<AGROW>
        end
    end
    for idx=1:numel(cvds)
        cvds{idx}.filterData=[];%#ok<AGROW>
    end
end

function res=saveLabels(cvds)
    res=[];

    for idx=1:numel(cvds)
        res(idx).description=cvds{idx}.description;
        res(idx).label='';
        if isa(cvds{idx},'cvdata')
            testId=cvds{idx}.id;
            if(testId>0)
                cvt=cvtest(testId);
                res(idx).label=cvt.label;

                cvt.label='';
            end
        end
    end
end

function restoreLabels(res,cvds)
    for idx=1:numel(cvds)
        cvds{idx}.description=res(idx).description;
        if~isempty(res(idx).label)
            testId=cvds{idx}.id;
            cvt=cvtest(testId);
            cvt.label=res(idx).label;
        end
    end
end

