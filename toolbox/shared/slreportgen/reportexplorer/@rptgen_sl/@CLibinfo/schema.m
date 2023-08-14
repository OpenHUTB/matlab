function schema









    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'CLibinfo',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';

    p=rptgen.prop(h,'isBlock','bool',true,...
    getString(message('RptgenSL:rsl_CLibInfo:blockLabel')),lic);




    p=rptgen.prop(h,'isLibrary','bool',true,...
    getString(message('RptgenSL:rsl_CLibInfo:libraryLabel')),lic);


    p=rptgen.prop(h,'isReferenceBlock','bool',true,...
    getString(message('RptgenSL:rsl_CLibInfo:refBlockLabel')),lic);




    p=rptgen.prop(h,'isLinkStatus','bool',true,...
    getString(message('RptgenSL:rsl_CLibInfo:linkStatusLabel')),lic);


    p=rptgen.prop(h,'Title',rptgen.makeStringType,getString(message('RptgenSL:rsl_CLibInfo:dependenciesLabel')),...
    getString(message('RptgenSL:rsl_CLibInfo:titleLabel')),lic);

    p=rptgen.prop(h,'Sort',{
    'Block',getString(message('RptgenSL:rsl_CLibInfo:blockLabel'))
    'Library',getString(message('RptgenSL:rsl_CLibInfo:libraryLabel'))
    'ReferenceBlock',getString(message('RptgenSL:rsl_CLibInfo:refBlockLabel'))
    'LinkStatus',getString(message('RptgenSL:rsl_CLibInfo:linkStatusLabel'))
    },'Block',getString(message('RptgenSL:rsl_CLibInfo:sortByLabel')),lic);


    p=rptgen.prop(h,'MergeRows','bool',false,...
    getString(message('RptgenSL:rsl_CLibInfo:mergeRepeatedLabel')),lic);



    rptgen.makeStaticMethods(h,{
    },{
    });
