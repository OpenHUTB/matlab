function updateResults(this)





    ctxInfo=this.ctxInfo;
    if isempty(ctxInfo)||~isstruct(ctxInfo)||...
        ~isfield(ctxInfo,'topModelName')||...
        isempty(ctxInfo.topModelName)||...
        ~isfield(ctxInfo,'cvdId')||...
        isempty(ctxInfo.cvdId)
        return
    end


    cvd=cv.coder.cvdatamgr.instance().get(ctxInfo.topModelName,ctxInfo.cvdId);
    if isempty(cvd)||~cvd.valid()
        return
    end


    currFileName=this.fileName;
    currPath=[pwd,filesep];
    if startsWith(currFileName,currPath)
        newName=strrep(currFileName,currPath,'');
        if~isempty(cvi.CovFilterUtils.getFilterId(newName))
            currFileName=newName;
        end
    end


    filters=cvd.filter;
    if isempty(filters)
        filters=currFileName;
    else
        if ischar(filters)
            filters={filters,currFileName};
        else
            filters=[filters(:);{currFileName}];
        end
    end
    filters=cellstr(filters);
    filters=unique(filters,'stable');




    filtersId=cell(size(filters));
    for ii=1:numel(filters)
        filtersId{ii}=cvi.CovFilterUtils.getFilterId(filters{ii});
    end
    idxBad=cellfun(@isempty,filtersId);
    filters(idxBad)=[];
    filtersId(idxBad)=[];
    if isempty(filters)
        filters='';
    else
        [~,idx]=unique(filtersId,'stable');
        filters=filters(idx);
    end



    cvd.filter=filters;


    if~isempty(this.ctxInfo)
        currFilterId=cvi.CovFilterUtils.getFilterId(this.fileName);
        filterInfo=cvd.filterAppliedStruct();
        for ii=1:numel(filterInfo)
            if strcmp(currFilterId,filterInfo(ii).fileNameId)
                this.ctxInfo.filterUUID=filterInfo(ii).uuid;
                this.ctxInfo.filterFileName=filterInfo(ii).fileName;
                break
            end
        end
    end


    if strcmpi(ctxInfo.filterReportViewCmd,'cvhtml')

        if~isempty(cvd.rptCtxInfo)&&isstruct(cvd.rptCtxInfo)&&...
            isfield(cvd.rptCtxInfo,'args')&&~isempty(cvd.rptCtxInfo.args)&&...
            iscell(cvd.rptCtxInfo.args)

            args=cvd.rptCtxInfo.args;
            cargs=args(cellfun(@ischar,args));
            idx=find(contains(cargs,'outputDir','IgnoreCase',true),1);
            if~isempty(idx)&&numel(cargs)>idx
                outputDir=cargs{idx+1};
                if~isfolder(outputDir)
                    error(message('Slvnv:simcoverage:ioerrors:FolderDoesNotExist'));
                end
            end


            cvhtmlSettings=args{1};
            if isa(cvhtmlSettings,'cvi.CvhtmlSettings')
                rptCtx=cvi.ReportUtils.getFilterCtxForReport(cvhtmlSettings,cvd);
                rptCtx.reportViewCmd='cvhtml';
                rptCtx.cvdataId=cvd.uniqueId;
                cvd.codeCovData.setFilterCtx(rptCtx);
            end


            args{end+1}=cvd.codeCovData;


            htmlFiles=codeinstrum.internal.codecov.CodeCovData.htmlReport(args{:});
            if~isempty(htmlFiles)
                url=cvi.ReportUtils.file_path_2_url(htmlFiles{1});
                web(url);
            end
        else

            cvhtml(cvd.moduleinfo.name,cvd);
        end
    end


