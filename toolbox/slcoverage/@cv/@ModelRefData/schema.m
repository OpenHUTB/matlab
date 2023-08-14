function schema

    pk=findpackage('cv');



    c=schema.class(pk,'ModelRefData');

    visibility='on';
    privateVisibility='off';










    p=schema.prop(c,'recordingModels','mxArray');

    p.Visible=visibility;

    p=schema.prop(c,'codeCovRecordingModels','mxArray');
    p.Visible=visibility;
    p.FactoryValue=[];

    p=schema.prop(c,'override','mxArray');

    p.Visible=visibility;

    p=schema.prop(c,'mdlBlkToCopyMdlMap','mxArray');
    p.Visible=visibility;
    p.FactoryValue=[];

    p=schema.prop(c,'accelModels','mxArray');
    p.Visible=visibility;
    p.FactoryValue=[];

    p=schema.prop(c,'notSupportedAccelModels','mxArray');
    p.Visible=visibility;
    p.FactoryValue=[];





    p=schema.method(c,'getMdlReferences','static');
    p=schema.method(c,'getExcludedModels','static');
    p=schema.method(c,'get_enable_rule_from_settings','static');
    p=schema.method(c,'assessModelRefEnabled','static');


