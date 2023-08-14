function[enabled,enabledTO]=getEnabledMetricNames(cvdata)




    enabled={};
    enabledTO={};
    if isDerived(cvdata)
        [metricNames,allToNames]=cvi.MetricRegistry.getAllMetricNames;

        tod=cvdata.metrics;

        for i=1:numel(metricNames)
            cn=metricNames{i};
            if isfield(tod,cn)&&~isempty(tod.(cn))
                enabled=[enabled,{cn}];%#ok<AGROW>
            end
        end

        if isfield(tod,'testobjectives')&&~isempty(tod.testobjectives)
            for i=1:numel(allToNames)
                cn=allToNames{i};
                if isfield(tod.testobjectives,cn)&&~isempty(tod.testobjectives.(cn))
                    enabledTO=[enabledTO,{cn}];%#ok<AGROW>
                end;
            end
        end


    else
        [enabled,enabledTO]=getEnabledMetricNames(cvtest(cvdata.id));
    end


