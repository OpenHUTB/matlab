function description=getCoverageDef(ssid,varargin)




    if nargin>1
        cvmetric=varargin{1};
        if isa(cvmetric,'cvmetric.Structural')
            metricNames=cvi.MetricRegistry.cvmetricToStr(cvmetric);
            metricNames=convertLegacyNames(metricNames);
        else
            metricNames=cvmetric;
        end
    else
        [allMetricNames,allTOMetricNames]=cvi.MetricRegistry.getAllMetricNames;
        metricNames=[allMetricNames,allTOMetricNames];
    end

    if~iscell(metricNames)
        metricNames={metricNames};
    end

    try
        handle=Simulink.ID.getHandle(ssid);
    catch

        if endsWith(ssid,'.m')
            handle=ssid;
        else
            description=[];
            return;
        end
    end
    sfId=[];
    if isa(handle,'Stateflow.Object')
        sfId=handle.id;
        handle=Simulink.ID.getHandle(Simulink.ID.getSimulinkParent(ssid));
    end
    blockCvId=SlCov.CoverageAPI.getCovId(handle,sfId);
    description=SlCov.CoverageAPI.getCoverageMetricsDef(blockCvId,metricNames);



    function res=convertLegacyNames(metricName)
        names={'condition','decision','mcdc','tableExec','sigrange','sigzise'};
        res=metricName;
        for idx=1:numel(names)
            if~isempty(strfind(metricName,names{idx}))
                res=names{idx};
                return;
            end
        end

