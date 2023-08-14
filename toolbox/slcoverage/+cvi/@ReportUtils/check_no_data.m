function ndm=check_no_data(cvd,metricNames)




    ndm={};

    topCvId=cv('get',cvd.rootID,'.topSlsf');

    for idx=1:numel(metricNames)
        cmn=metricNames{idx};




        if isfield(cvd.metrics,cmn)&&isempty(cvd.metrics.(cmn))
            ndm{end+1}=cmn;
        elseif strcmpi(cmn,'sigrange')||...
            strcmpi(cmn,'sigsize')
            continue;
        else
            if isempty(cvd.codeCovData)
                testObjEnum=cvi.MetricRegistry.getEnum(cmn);
                md=cv('MetricGet',topCvId,testObjEnum,'.dataCnt.deep');
                if isempty(md)||(md==0)
                    ndm{end+1}=cmn;
                end
            end
        end
    end





