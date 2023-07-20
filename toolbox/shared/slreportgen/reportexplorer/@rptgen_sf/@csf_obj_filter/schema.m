function schema






    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_obj_filter',pkgRG.findclass('rptcomponent'));


    allTypes=listReportableTypes(rptgen_sf.appdata_sf);

    p=rptgen.prop(h,'ObjectType',[allTypes,allTypes],'Machine',...
    getString(message('RptgenSL:rsf_csf_obj_filter:objectTypeLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'repMinChildren','double',[0],...
    getString(message('RptgenSL:rsf_csf_obj_filter:runIfGivenChildCountLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'addAnchor','bool',true,...
    getString(message('RptgenSL:rsf_csf_obj_filter:automaticallyInsertAnchorLabel')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
    });
