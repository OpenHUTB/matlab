




function table=getSimscapeMetricDescrTable


    persistent pSimscapeDescr


    if isempty(pSimscapeDescr)
        pSimscapeDescr={...
        0,...
        'cvmetric_Simscape_mode',...
        'SCM',...
        0,...
        getString(message('Slvnv:simcoverage:simscapeModeMetric'));...
        };
        pSimscapeDescr=cvi.MetricRegistry.setMetricEnums(pSimscapeDescr);
    end

    table=pSimscapeDescr;

