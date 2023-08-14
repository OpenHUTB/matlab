function res=compareChecksumsAndMetricSettings(cvd1,cvd2)




    areChecksumsEqual=isequal(cvd1.checksum,cvd2.checksum);
    if strcmp(cv('Feature','CreateStructuralAndMetricChecksums'),'off')
        res=areChecksumsEqual;
    else
        res=(areChecksumsEqual&&~isequal(cvd1.checksum,cvi.TopModelCov.derivedDataIncompatibleChecksum))||...
        (isequal(cvd1.structuralChecksum,cvd2.structuralChecksum)&&...
        areBothMetricsDisabledOrMetricChecksumsEqual('relationalop','relBndMetricChecksum')&&...
        areBothMetricsDisabledOrMetricChecksumsEqual('overflowsaturation','satOvfMetricChecksum'));
    end

    function bool=areBothMetricsDisabledOrMetricChecksumsEqual(metricName,metricChecksumFieldName)
        bool=~(cvd1.testSettings.(metricName)||cvd2.testSettings.(metricName))||...
        isequal(cvd1.(metricChecksumFieldName),cvd2.(metricChecksumFieldName));
    end

end
