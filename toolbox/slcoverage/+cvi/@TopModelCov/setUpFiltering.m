function[statusChanged,newFilterId]=setUpFiltering(topModelH,cvd,rootId)



    try
        beforeSim=true;
        if nargin<3

            rootId=cvd.rootId;
            beforeSim=false;
        end
        newFilterId='';
        topCvId=cv('get',rootId,'.topSlsf');
        statusChanged=false;

        filterFileNames=cvd.filter;

        dbVersion=cvd.dbVersion;
        lessThan22a=str2double(dbVersion(3:end-2))<2022;
        filterAppliedStruct=getInternalFilterAppled(cvd);
        internalFilterId='';
        if~isempty(filterAppliedStruct)
            internalFilterId=[filterAppliedStruct.fileNameId];
        end
        if~isempty(filterFileNames)
            if~iscell(filterFileNames)
                filterFileNames={filterFileNames};
            end
            for idx=1:numel(filterFileNames)
                fileName=filterFileNames{idx};
                [fileNameId,foundFileName,err]=cvi.CovFilterUtils.getFilterId(fileName,topModelH);
                filterAppliedStruct=cvi.CovFilterUtils.setFilterApplied(filterAppliedStruct,foundFileName,fileName,fileNameId,err);
                if~isempty(err)
                    filterFileNames{idx}='';
                else
                    filterFileNames{idx}=foundFileName;
                end
            end
        end

        if~isempty(filterAppliedStruct)
            newFilterId=[filterAppliedStruct.fileNameId];
        end

        oldFilterId=cvi.CovFilterUtils.getFilterAppliedId(cvi.TopModelCov.getFilterApplied(rootId));
        cvdataFilterId=cvd.filterApplied;

        if strcmpi(newFilterId,oldFilterId)&&strcmpi(newFilterId,cvdataFilterId)
            filterAppliedStruct=cvi.CovFilterUtils.updateErroredFilterApplied(cvi.TopModelCov.getFilterApplied(rootId),filterAppliedStruct);
            cvi.TopModelCov.setModelCovFilterApplied(cv('get',rootId,'.modelcov'),filterAppliedStruct);
            return;
        end


        if~isempty(oldFilterId)
            cvi.TopModelCov.resetFilter(rootId,cvd,beforeSim);

            if isempty(newFilterId)

                if~isempty(filterAppliedStruct)
                    filterAppliedStruct=filterAppliedStruct({filterAppliedStruct.err}~="");
                end
                cvi.TopModelCov.setModelCovFilterApplied(cv('get',rootId,'.modelcov'),filterAppliedStruct);
            end
            statusChanged=true;
        end

        if isempty(newFilterId)
            return;
        end

        filterAPI=slcoverage.Filter;
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



        filterAppliedStruct=updateInternalFilterApplied(filterAppliedStruct,filterAPI,cvd,lessThan22a);
        cvi.TopModelCov.setModelCovFilterApplied(cv('get',rootId,'.modelcov'),filterAppliedStruct);
        filter=filterAPI.filter;
        filter.supportExecutionOnlyBlocks=~isempty(internalFilterId);


        if isempty(newFilterId)||filter.isEmpty
            return;
        end
        statusChanged=true;


        if~beforeSim
            if SlCov.CovMode.isGeneratedCode(cvd.simMode)&&isa(cvd.codeCovData,'SlCov.results.CodeCovData')
                cvi.CovFilterUtils.applyFilterOnCode(cvd.codeCovData,filter);
                return
            end
            if cvd.isSimulinkCustomCode&&isa(cvd.sfcnCovData,'SlCov.results.CodeCovDataGroup')
                cvi.CovFilterUtils.applyFilterOnCode(cvd.sfcnCovData,filter,true);
                return
            end
        end

        slsfobjs=getAllSlsfObjs(topCvId);



        sfcnCovRes=[];
        sfcnCvId=cell(0,3);
        if~isempty(slsfobjs)&&~beforeSim
            try
                sfcnCovRes=cvi.SFunctionCov.extractResultsInfo({cvd},slsfobjs);
            catch

            end
        end

        for idx=1:numel(slsfobjs)

            cvid=slsfobjs(idx);
            ssid=cvi.TopModelCov.getSID(cvid);
            if isempty(ssid)
                continue;
            end
            ssid=cvd.mapFromHarnessSID(ssid);
            [filtered,prop,rationale]=filter.isFiltered(ssid);
            if filtered

                if prop.includeChildren
                    cv('set',cvid,'.allChildrenFiltered',1);
                    cv('SetFilterRationale',cvid,filter.getRationale(ssid));
                end
                checkStateflowAllFiltered(cvid);

                if prop.mode==0
                    cv('set',cvid,'.isDisabled',1);
                    cv('SetFilterRationale',cvid,rationale);

                    if~isempty(sfcnCovRes)&&sfcnCovRes.covId2InstanceInfo.isKey(cvid)
                        sfcnCvId=[sfcnCvId;{cvid,true,rationale}];%#ok<AGROW>
                    end

                elseif prop.mode==1
                    slsfIsFilterd=checkSubPropFilter(filter,cvid,ssid);
                    if~slsfIsFilterd
                        cv('set',cvid,'.isJustified',1);
                        cv('SetFilterRationale',cvid,rationale);

                        if~isempty(sfcnCovRes)&&sfcnCovRes.covId2InstanceInfo.isKey(cvid)
                            sfcnCvId=[sfcnCvId;{cvid,false,rationale}];%#ok<AGROW>
                        end
                    end
                end
            else
                checkSubPropFilter(filter,cvid,ssid);
            end
        end


        if~isempty(sfcnCovRes)
            applyFilterOnSFunction(cvd,filter,sfcnCovRes,sfcnCvId);
        end

    catch MEx
        throw(MEx);
    end


    function filterAppliedStruct=updateInternalFilterApplied(filterAppliedStruct,filter,cvd,lessThan22a)
        filterData=cvd.filterData;
        if isempty(filterData)
            return;
        end

        for idx=1:numel(filterData)

            cfd=filterData(idx);

            if(strcmp(cfd.type,'sfvariant_nonVarTrans')||...
                strcmp(cfd.type,'startupvariant'))&&...
                (slfeature('SlCovConsistentReportingOfVariants')&&...
                ~cvd.excludeInactiveVariants)
                continue;
            end

            rat=cvi.ReportUtils.createInternalRationale(cfd.type);




            for idx1=1:numel(cfd.rules)
                cr=cfd.rules{idx1};
                selector=evalin('base',cr);
                if lessThan22a&&strcmp(cfd.type,'sfvariant')
                    if cvd.excludeInactiveVariants
                        filter.addExcludeRule(selector,rat);
                    else

                        if strcmp(selector.Type,'Transition')
                            sfId=Simulink.ID.getHandle(selector.Id);
                            if sfId.IsVariant
                                filter.addExcludeRule(selector,rat);
                            end
                        end
                    end
                else
                    filter.addExcludeRule(selector,rat);
                end
            end
            ts=cvi.TopModelCov.getFilterAppliedStruct();
            ts.isInternal=1;
            ts.fileNameId=cfd.id;
            if isempty(filterAppliedStruct)
                filterAppliedStruct=ts;
            else
                filterAppliedStruct(end+1)=ts;%#ok<AGROW>
            end
        end



        function checkStateflowAllFiltered(cvid)
            handle=cv('get',cvid,'.handle');

            if cv('get',cvid,'.origin')==1
                if slprivate('is_stateflow_based_block',handle)
                    cv('set',cvid,'.allChildrenFiltered',1);
                end
            elseif cv('get',cvid,'.origin')==2
                if sfprivate('is_truth_table_fcn',handle)
                    cv('set',cvid,'.allChildrenFiltered',1);
                end
            end

            function filterAppliedStruct=getInternalFilterAppled(cvd)
                filterData=cvd.filterData;
                filterAppliedStruct=[];
                if~isempty(filterData)
                    if slfeature('SlCovConsistentReportingOfVariants')
                        if cvd.excludeInactiveVariants
                            filterAppliedStruct=cvi.TopModelCov.getFilterAppliedStruct();
                            filterAppliedStruct.isInternal=1;
                            filterAppliedStruct.fileNameId=filterData.id;
                        else
                            for idx=1:length(filterData)
                                if~(strcmp(filterData(idx).type,'sfvariant_nonVarTrans')||...
                                    strcmp(filterData(idx).type,'startupvariant'))

                                    filterAppliedStruct=cvi.TopModelCov.getFilterAppliedStruct();
                                    filterAppliedStruct.isInternal=1;
                                    filterAppliedStruct.fileNameId=filterData(idx).id;
                                    break;
                                end
                            end
                        end
                    else
                        filterAppliedStruct=cvi.TopModelCov.getFilterAppliedStruct();
                        filterAppliedStruct.isInternal=1;
                        filterAppliedStruct.fileNameId=filterData.id;
                    end
                end


                function slsfIsFilterd=checkSubPropFilter(filter,cvid,ssid)
                    slsfIsFilterd=false;
                    filtObjs=cvi.TopModelCov.getFilteredMetricsBySubProp(filter,cvid,ssid);
                    if~isempty(filtObjs)
                        fn=fields(filtObjs);
                        for idx=1:numel(fn)
                            cff=filtObjs.(fn{idx});
                            for oidx=1:numel(cff.objs)
                                co=cff.objs(oidx);
                                if~isempty(cff.objectiveModes)&&...
                                    ~isempty(cff.objectiveModes{oidx})
                                    if cff.objectiveModes{oidx}
                                        cv('set',co,'.isJustified',1);
                                    else
                                        cv('set',co,'.isDisabled',1);
                                    end
                                    cv('SetFilterRationale',co,cff.rationale{oidx});
                                elseif~isempty(cff.outcomeIdx)
                                    cv('set',co,'.filteredOutcomes',cff.outcomeIdx{oidx});
                                    cv('set',co,'.filteredOutcomeModes',cff.outcomeModes{oidx});
                                    or=cff.outcomeRationale{oidx};
                                    if~isempty(or{1})
                                        ors=char(join(or,cvi.ReportUtils.rationaleSeparator));
                                        cv('SetFilterOutcomeRationale',co,ors);
                                    end
                                else

                                    slsfIsFilterd=true;
                                    cv('set',co,'.isDisabled',1);
                                    cv('SetFilterRationale',co,cff.rationale{oidx});
                                end
                            end
                        end

                    end


                    function slsfobjs=getAllSlsfObjs(topCovId)


                        all=cv('DecendentsOf',topCovId);
                        slsfobjs=cv('find',all,'.isa',cv('get','default','slsfobj.isa'));


                        function applyFilterOnSFunction(cvd,filter,sfcnCovRes,sfcnCvId)


                            for ii=1:size(sfcnCvId,1)
                                sfcnInstInfo=sfcnCovRes.covId2InstanceInfo(sfcnCvId{ii,1});
                                sfcnCovData=cvd.sfcnCovData.get(sfcnInstInfo.name);
                                sfcnCovData.annotateAllFiles(sfcnCvId{ii,2},sfcnCvId{ii,3},sfcnInstInfo.instanceIdx);
                            end


                            codeInfoProp=filter.getAllCodeInfo();
                            badIdx=[];
                            for jj=1:numel(codeInfoProp)
                                [~,ssid]=SlCov.FilterEditor.decodeCodeFilterInfo(codeInfoProp{jj}.value);
                                if isempty(ssid)
                                    badIdx=[badIdx,jj];%#ok<AGROW>
                                end
                            end
                            codeInfoProp(badIdx)=[];


                            decEnum=cvi.MetricRegistry.getEnum('decision');
                            condEnum=cvi.MetricRegistry.getEnum('condition');
                            mcdcEnum=cvi.MetricRegistry.getEnum('mcdc');
                            relopEnum=cvi.MetricRegistry.getEnum('cvmetric_Structural_relationalop');

                            cvIds=sfcnCovRes.covId2InstanceInfo.keys();
                            cvIds=setdiff([cvIds{:}],[sfcnCvId{:,1}]);
                            for ii=1:numel(cvIds)
                                sfcnId=SlCov.FilterEditor.getSSID(cv('get',cvIds(ii),'.handle'));
                                if isempty(sfcnId)
                                    continue
                                end
                                sfcnId=cvd.mapFromHarnessSID(sfcnId);
                                sfcnInstInfo=sfcnCovRes.covId2InstanceInfo(cvIds(ii));
                                sfcnCovData=cvd.sfcnCovData.get(sfcnInstInfo.name);
                                hasExtraInfo=false;

                                for jj=1:numel(codeInfoProp)
                                    [codeInfo,ssid]=SlCov.FilterEditor.decodeCodeFilterInfo(codeInfoProp{jj}.value);
                                    if~strcmp(sfcnId,ssid)
                                        continue
                                    end
                                    isFilter=~logical(codeInfoProp{jj}.mode);
                                    if SlCov.FilterEditor.isCodeFilterFileInfo(codeInfo)
                                        sfcnCovData.annotateFile(isFilter,codeInfoProp{jj}.Rationale,codeInfo{:},sfcnInstInfo.instanceIdx);
                                    elseif SlCov.FilterEditor.isCodeFilterFunInfo(codeInfo)
                                        sfcnCovData.annotateFunction(isFilter,codeInfoProp{jj}.Rationale,codeInfo{:},sfcnInstInfo.instanceIdx);
                                    elseif SlCov.FilterEditor.isCodeFilterDecInfo(codeInfo)||...
                                        SlCov.FilterEditor.isCodeFilterCondInfo(codeInfo)||...
                                        SlCov.FilterEditor.isCodeFilterMCDCInfo(codeInfo)||...
                                        SlCov.FilterEditor.isCodeFilterRelBoundInfo(codeInfo)
                                        sfcnCovData.annotateExpression(isFilter,codeInfoProp{jj}.Rationale,codeInfo{:},sfcnInstInfo.instanceIdx);
                                    else
                                        continue
                                    end
                                    hasExtraInfo=true;
                                end

                                if hasExtraInfo

                                    res=sfcnCovData.getInstanceResults(sfcnInstInfo.instanceIdx);


                                    updateMetricObject(cvIds(ii),decEnum,res,sfcnCovData.CodeTr.getDecisionPoints(sfcnCovData.CodeTr.Root));
                                    updateMetricObject(cvIds(ii),condEnum,res,sfcnCovData.CodeTr.getConditionPoints(sfcnCovData.CodeTr.Root));
                                    updateMetricObject(cvIds(ii),mcdcEnum,res,sfcnCovData.CodeTr.getMCDCPoints(sfcnCovData.CodeTr.Root));
                                    updateMetricObject(cvIds(ii),relopEnum,res,sfcnCovData.CodeTr.getRelationalBoundaryPoints(sfcnCovData.CodeTr.Root));
                                end
                            end

                            cvd.fillCachedSFcnCovInfoStruct();


                            function updateMetricObject(cvId,metricEnum,res,covPts)

                                if isempty(covPts)
                                    return
                                end

                                isDec=isa(covPts(1),'internal.cxxfe.instrum.DecisionPoint');
                                isCond=isa(covPts(1),'internal.cxxfe.instrum.ConditionPoint');
                                isRelop=isa(covPts(1),'internal.cxxfe.instrum.RelationalBoundaryPoint');

                                mObjs=cv('MetricGet',cvId,metricEnum,'.baseObjs');
                                for jj=1:numel(covPts)
                                    covPt=covPts(jj);
                                    filterDef=res.getEffectiveFilter(covPt);
                                    if~isempty(filterDef)
                                        if filterDef.mode==internal.codecov.FilterMode.EXCLUDED
                                            if isDec||isCond
                                                cv('set',mObjs(jj),'.isDisabled',1);
                                                if~isempty(filterDef.filterRationale)
                                                    cv('SetFilterRationale',mObjs(jj),filterDef.filterRationale);
                                                end
                                            end
                                        else
                                            if isDec||isCond
                                                cv('set',mObjs(jj),'.isJustified',1);
                                                if~isempty(filterDef.filterRationale)
                                                    cv('SetFilterRationale',mObjs(jj),filterDef.filterRationale);
                                                end
                                            end
                                        end
                                    else
                                        try
                                            if~SlCov.isCodeOutcomeFilterFeatureOn()
                                                continue
                                            end
                                            idx=zeros(1,covPt.outcomes.Size());
                                            rat=cell(1,covPt.outcomes.Size());
                                            for kk=1:covPt.outcomes.Size()
                                                instrPt=covPt.outcomes(kk);
                                                filterDef=res.getLocalFilter(instrPt);
                                                if~isempty(filterDef)
                                                    idx(kk)=kk;
                                                    rat{kk}=filterDef.filterRationale;
                                                end
                                            end
                                            idx(idx==0)=[];
                                            if~isempty(idx)
                                                cv('set',mObjs(jj),'.filteredOutcomeModes',ones(size(idx),'int32'));
                                                if isCond


                                                    for kk=1:numel(idx)
                                                        if idx(kk)==2
                                                            idx(kk)=1;
                                                        elseif idx==1
                                                            idx(kk)=2;
                                                        end
                                                    end
                                                elseif isRelop


                                                    if covPt.outcomes.Size()==3
                                                        for kk=1:numel(idx)
                                                            if idx(kk)==2
                                                                idx(kk)=3;
                                                            elseif idx(kk)==3
                                                                idx(kk)=2;
                                                            end
                                                        end
                                                    end
                                                end
                                                cv('set',mObjs(jj),'.filteredOutcomes',idx);
                                                rat(cellfun(@isempty,rat))=[];
                                                if~isempty(rat)
                                                    ors=char(join(rat,cvi.ReportUtils.rationaleSeparator));
                                                    cv('SetFilterOutcomeRationale',mObjs(jj),ors);
                                                end
                                            end
                                        catch MEx

                                            MEx;%#ok<VUNUS>
                                        end
                                    end
                                end


