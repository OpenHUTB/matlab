



function res=applyFilter(this)

    res=false;

    if~this.valid()||(isempty(this.filter)&&isempty(this.filterApplied))
        return
    end

    [filterStatusChanged,datedFilterName]=setUpFiltering(this);
    dataFilterStatusChanged=~strcmpi(this.filterApplied,datedFilterName);

    if~filterStatusChanged&&~dataFilterStatusChanged
        return
    end

    this.filterApplied=datedFilterName;
    res=true;


    function[statusChanged,newFilterId]=setUpFiltering(cvd)

        statusChanged=false;
        newFilterId='';

        filterFileNames=cvd.filter;

        filterAppliedStruct=getInternalFilterApplied(cvd.filterData);
        internalFilterId='';
        if~isempty(filterAppliedStruct)
            internalFilterId=[filterAppliedStruct.fileNameId];
        end
        if~isempty(filterFileNames)
            filterFileNames=cellstr(filterFileNames);
            for idx=1:numel(filterFileNames)
                fileName=filterFileNames{idx};
                [fileNameId,foundFileName,err]=cvi.CovFilterUtils.getFilterId(fileName);
                filterAppliedStruct=cvi.CovFilterUtils.setFilterApplied(filterAppliedStruct,foundFileName,fileName,fileNameId,err);
                if~isempty(err)
                    filterFileNames{idx}='';
                else
                    filterFileNames{idx}=foundFileName;
                end
            end
        end

        if~isempty(filterAppliedStruct)
            [~,idx]=unique({filterAppliedStruct.fileNameId},'stable');
            filterAppliedStruct=filterAppliedStruct(idx);
            newFilterId=[filterAppliedStruct.fileNameId];
        end

        oldFilterId=cvi.CovFilterUtils.getFilterAppliedId(cvd.filterAppliedStruct);
        cvdataFilterId=cvd.filterApplied;

        if strcmpi(newFilterId,oldFilterId)&&strcmpi(newFilterId,cvdataFilterId)
            cvd.filterAppliedStruct=cvi.CovFilterUtils.updateErroredFilterApplied(cvd.filterAppliedStruct,filterAppliedStruct);
            return
        end


        if~isempty(oldFilterId)
            cvd.codeCovData.resetFilters();

            if isempty(newFilterId)

                if~isempty(filterAppliedStruct)
                    filterAppliedStruct=filterAppliedStruct({filterAppliedStruct.err}~="");
                end
                cvd.filterAppliedStruct=filterAppliedStruct;
            end
            statusChanged=true;
        end

        if isempty(newFilterId)
            return
        end

        filterAPI=slcoverage.Filter();
        if~isempty(filterFileNames)
            filterFileNames(filterFileNames=="")=[];
        end


        for idx=1:numel(filterFileNames)
            tmpFilter=slcoverage.Filter(filterFileNames{idx});
            filterAppliedStruct=cvi.CovFilterUtils.updateFilterApplied(filterAppliedStruct,filterFileNames{idx},tmpFilter.filter);
            allRules=tmpFilter.rules;
            for ridx=1:numel(allRules)
                tr=allRules(ridx);
                tr.Rationale=cvi.ReportUtils.encodeRationale(tr.Rationale,tmpFilter.filter.getUUID);

                filterAPI.addRule(allRules(ridx));
            end
        end




        cvd.filterAppliedStruct=updateInternalFilterApplied(filterAppliedStruct,filterAPI,cvd.filterData);
        filter=filterAPI.filter;
        filter.supportExecutionOnlyBlocks=~isempty(internalFilterId);

        if isempty(newFilterId)||filter.isEmpty
            return
        end

        statusChanged=true;


        cvi.CovFilterUtils.applyFilterOnCode(cvd.codeCovData,filter);


        function filterAppliedStruct=getInternalFilterApplied(filterData)%#ok<INUSD> 
            filterAppliedStruct=[];

...
...
...
...
...
...
...


            function filterAppliedStruct=updateInternalFilterApplied(filterAppliedStruct,filter,filterData)%#ok<INUSD> 

                if isempty(filterData)
                    return
                end


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


