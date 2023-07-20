



classdef ReportUtils

    properties(Constant)
        rationaleSeparator='#RS#'
        filterUUIDSeparator='#FID#'
        internalRationalePrefix='#IRP#'
    end

    methods(Static=true)
        noData=check_no_data(test,metricNames,toMetricNames)
        url=file_path_2_url(filepath)
        fileName=file_url_2_path(url)
        [metricNames,toMetricNames]=get_all_metric_names(allTests)
        [metricNames,toMetricNames]=get_common_metric_names(allTests)
        [enabledMetricNames,enabledTOMetricNames,enabledMetricsStruct]=...
        getMetricsForSummary(allTests,recordedMetricNames,recordedTOMetricNames,options)
        fullPath=get_report_file_name(modelName,varargin)
        out=obj_diag_named_link(id,addtxt,commandType,isLinked)
        out=cr_to_space(in)
        out=obj_anchor(id,str)
        out=obj_link(id,str)
        ret=getOptionsTable;
        options=parseOptionString(options,optionStr)
        displayOptionsHelp(filename,varargin)
        informerUddObj=closeInformer(currModelcovId)
        out=str_to_html(in)
        out=html_to_str(in)
        str=getTextOf(id,index,elements,detailLevel)
        [modelH,modelName,status]=checkModelLoaded(testObj,cvd,toThrow)
        [topModelName,modelName,ownerModel,errmsg]=loadTopModelAndRefModels(covdata,covMode)
        item=get_script_to_truth_table_map(map,line)
        [path,fileName,ext,msg]=getFilePartsWithWriteChecks(filename,neededExt,varargin)
        [path,fileName,ext]=getFilePartsWithReadChecks(filename,neededExt)
        [res,userWrite]=checkUserWrite(filePath)
        fullFileName=appendFileExtAndPath(filename,neededExt)
        outStr=getJScriptSection()
        outStr=getCSSSection()
        outStr=addCSSRule(inStr,rule)
        prepareImageFiles(startDir)
        [modelCovId,scriptName]=getModelCovId(covdata)
        str=getFormatterText(messageId,insertTxt)
        linkStr=getReportLink(slsfId)
        reportLinkCallBack(ref)
        reportContextCallBack(command,testId,contextType,topModelName)
        [isBlockHarness,topModelName,rootId,errmsg,ownerModel]=checkHarnessData(covdata)
        req=getReqTableRow(sfId,chartId)

        function rationale=createInternalRationale(rationale)
            rationale=[cvi.ReportUtils.internalRationalePrefix,rationale];
        end

        function[res,rationale]=checkInternalRationale(rationale)
            res=false;
            if startsWith(rationale,cvi.ReportUtils.internalRationalePrefix)
                res=true;
                idx=numel(cvi.ReportUtils.internalRationalePrefix);
                rationale=rationale(idx:end);
            end
        end

        function rat=encodeRationale(rat,uuid)
            rat=[rat,cvi.ReportUtils.filterUUIDSeparator,uuid];
        end

        function[rationale,uuid]=decodeRationale(rat)
            rationale='';
            uuid='';
            if isempty(rat)||~ischar(rat)
                return;
            end
            ratAndUUID=split(rat,cvi.ReportUtils.filterUUIDSeparator);
            rationale=ratAndUUID{1};
            if numel(ratAndUUID)>1
                uuid=ratAndUUID{2};
            end
        end

        function[rationale,uuid]=getFilterRationale(cvId,isOutcome)
            if nargin<2
                isOutcome=false;
            end
            rationale='';
            uuid='';
            if isOutcome
                rat=cv('GetFilterOutcomeRationale',cvId);
                if~isempty(rat)
                    rat=split(rat,cvi.ReportUtils.rationaleSeparator);
                    for idx=1:numel(rat)
                        [rationale{idx},uuid{idx}]=cvi.ReportUtils.decodeRationale(rat{idx});
                    end
                end
            else
                rat=cv('GetFilterRationale',cvId);
                if~isempty(rat)
                    [rationale,uuid]=cvi.ReportUtils.decodeRationale(rat);
                end
            end
        end

        function filterCtx=getFilterCtxForReport(options,cvd)
            [filterCtxId,reportViewCmd]=options.getFilterCtxId();
            filterCtx.filterCtxId=filterCtxId;
            filterCtx.reportViewCmd=reportViewCmd;
            filterCtx.cvdataId=cvd.id;
            if isa(cvd,'cv.coder.cvdata')
                filterCtx.appliedFilters=cvd.filterAppliedStruct;
            else
                filterCtx.appliedFilters=cv('get',cvd.rootId,'.filterApplied');
            end
            filterCtx.filterFileNames='';
            if~isempty(filterCtx.appliedFilters)
                for idx=1:numel(filterCtx.appliedFilters)
                    if isempty(filterCtx.appliedFilters(idx).filterName)
                        filterCtx.appliedFilters(idx).filterName=getString(message('Slvnv:simcoverage:cvresultsexplorer:UntitledFilterName'));
                    end
                end
                fileNames=join({filterCtx.appliedFilters.fileName},',');
                filterCtx.filterFileNames=fileNames{1};
            end
        end
    end

end


