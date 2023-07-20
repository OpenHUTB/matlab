function schema()




    hPackage=findpackage('Simulink');

    hThisClass=schema.class(hPackage,'SampleTimeWidget');

    schema.method(hThisClass,'getSampleTimeWidget','static');
    schema.method(hThisClass,'callbackAdvancedSampleTimeWidget','static');
    schema.method(hThisClass,'updateSampleTimeWidgets','static');
    schema.method(hThisClass,'getSampleTimeMask','static');
    schema.method(hThisClass,'getCustomDdgWidget','static');



