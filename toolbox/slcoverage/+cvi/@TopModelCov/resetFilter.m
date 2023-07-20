function resetFilter(rootId,cvd,beforeSim)





    if nargin<2
        cvd=[];
    end


    if~beforeSim&&SlCov.CovMode.isGeneratedCode(cvd.simMode)&&...
        isa(cvd.codeCovData,'SlCov.results.CodeCovData')
        cvd.codeCovData.resetFilters();
    elseif~beforeSim&&...
        isa(cvd.sfcnCovData,'SlCov.results.CodeCovDataGroup')&&...
        cvd.isSimulinkCustomCode
        allCodeCov=cvd.sfcnCovData.getAll();
        for ii=1:numel(allCodeCov)
            allCodeCov(ii).resetFilters();
        end
    else
        roots=cv('RootsIn',cv('get',rootId,'.modelcov'));
        slsfobjs=[];
        metricobjs=[];
        for idx=1:numel(roots)
            rootId=roots(idx);
            topCvId=cv('get',rootId,'.topSlsf');
            [tslsfobjs,tmetricobjs]=getAllSlsfObjs(topCvId);
            slsfobjs=unique([slsfobjs,tslsfobjs]);
            metricobjs=unique([metricobjs,tmetricobjs]);
        end
        for idx=1:numel(slsfobjs)
            cvid=slsfobjs(idx);
            cv('set',cvid,'.allChildrenFiltered',0);
            cv('set',cvid,'.isDisabled',0);
            cv('set',cvid,'.isJustified',0);
            cv('set',cvid,'.filterRationale',[]);
        end
        if~isempty(metricobjs)
            cv('set',metricobjs,'.isDisabled',0);
            cv('set',metricobjs,'.isJustified',0);
            cv('set',metricobjs,'.filteredOutcomes',[]);
            cv('set',metricobjs,'.filteredOutcomeModes',[]);
            cv('set',metricobjs,'.filterRationale',[]);
            cv('set',metricobjs,'.outcomeRationale',[]);
        end


        if~beforeSim&&isa(cvd.sfcnCovData,'SlCov.results.CodeCovDataGroup')
            cvds=cvd.sfcnCovData.getAll();
            for ii=1:numel(cvds)
                cvds(ii).resetFilters();
            end
            cvd.fillCachedSFcnCovInfoStruct();
        end
    end



    function[slsfobjs,metricobjs]=getAllSlsfObjs(topCovId)

        all=cv('DecendentsOf',topCovId);
        slsfobjs=cv('find',all,'.isa',cv('get','default','slsfobj.isa'));
        metricNames=SlCov.FilterEditor.getSupportedMetricNames;
        metricobjs=[];
        for idx=1:numel(metricNames)
            metricEnum=cvi.MetricRegistry.getEnum(metricNames{idx});
            mObjs=cv('MetricGet',slsfobjs,metricEnum,'.baseObjs');
            metricobjs=[metricobjs,mObjs(:)'];%#ok<AGROW>
        end
