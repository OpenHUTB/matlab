












function setupCoverageSettings(tf,cvResult)
    cs=tf.getCoverageSettings;
    cs.RecordCoverage=true;
    cs.MdlRefCoverage=true;

    metricStr='';
    fieldNames=fields(cvResult.metrics);
    for k=1:length(fieldNames)
        cov=cvResult.metrics.(fieldNames{k});
        if(isempty(cov))
            continue;
        end
        switch(fieldNames{k})
        case 'decision'
            metricStr=[metricStr,'d'];
        case 'condition'
            metricStr=[metricStr,'c'];
        case 'mcdc'
            metricStr=[metricStr,'m'];
        case 'tableExec'
            metricStr=[metricStr,'t'];
        case 'sigrange'
            metricStr=[metricStr,'r'];
        case 'sigsize'
            metricStr=[metricStr,'z'];
        end
    end
    cs.MetricSettings=metricStr;
end