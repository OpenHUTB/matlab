function schema






    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_auto_table',pkgRG.findclass('rpt_auto_table'));


    p=rptgen.prop(h,'NameType',{
    'name',getString(message('RptgenSL:rsf_csf_auto_table:objectNameLabel'))
    'sfname',getString(message('RptgenSL:rsf_csf_auto_table:objectNameWithSFPathLabel'))
    'slsfname',getString(message('RptgenSL:rsf_csf_auto_table:objectNameWithSLSFPathLabel'))
    },'name',getString(message('RptgenSL:rsf_csf_auto_table:displayNameLabel')),'SIMULINK_Report_Gen');




    rptgen.makeStaticMethods(h,{
    },{
'atGetName'
'atGetObjects'
'atGetPropertyList'
'atGetPropertySource'
'atIgnoreValue'
    });
