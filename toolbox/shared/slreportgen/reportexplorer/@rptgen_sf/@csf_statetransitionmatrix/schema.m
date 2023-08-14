function schema










    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csf_statetransitionmatrix',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'TitleMode',{
    'none',getString(message('RptgenSL:rsf_csf_statetransitionmatrix:noTitleLabel'))
    'auto',getString(message('RptgenSL:rsf_csf_statetransitionmatrix:useSFNameLabel'))
    'manual',[getString(message('RptgenSL:rsf_csf_statetransitionmatrix:customLabel')),':']
    },'none',...
    getString(message('RptgenSL:rsf_csf_statetransitionmatrix:titleLabel')),lic);


    p=rptgen.prop(h,'Title',rptgen.makeStringType,getString(message('RptgenSL:rsf_csf_statetransitionmatrix:STTLabel')),...
    '',lic);


    p=rptgen.prop(h,'DisplayConditionActions','bool',true,getString(message('RptgenSL:rsf_csf_statetransitionmatrix:displayConditionActions')),lic);


    p=rptgen.prop(h,'RunTimeSTTUtils','MATLAB array',[],'',2);


    rptgen.makeStaticMethods(h,{
'findSTTs'
    });
