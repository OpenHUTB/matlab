function schema










    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_statetransitiontable',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'TitleMode',{
    'none',getString(message('RptgenSL:rsf_csf_statetransitiontable:noTitleLabel'))
    'auto',getString(message('RptgenSL:rsf_csf_statetransitiontable:useSFNameLabel'))
    'manual',[getString(message('RptgenSL:rsf_csf_statetransitiontable:customLabel')),':']
    },'none',...
    getString(message('RptgenSL:rsf_csf_statetransitiontable:titleLabel')),lic);


    p=rptgen.prop(h,'Title',rptgen.makeStringType,getString(message('RptgenSL:rsf_csf_statetransitiontable:STTLabel')),...
    '',lic);


    p=rptgen.prop(h,'RunTimeSTTUtils','MATLAB array',[],'',2);


    rptgen.makeStaticMethods(h,{
'findSTTs'
    });