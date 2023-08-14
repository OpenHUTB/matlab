




function metricName=cvmetricToStr(cvmetricHandle)

    className=class(cvmetricHandle);
    [enumVals,enumNames]=enumeration(className);

    metricName=enumNames{enumVals==cvmetricHandle};
    metricName=[className,'.',metricName];
    metricName=strrep(metricName,'.','_');