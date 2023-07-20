function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'CAnnotationLoop',pkgRG.findclass('rpt_looper'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'SortBy',{
    'alpha',getString(message('RptgenSL:rsl_CAnnotationLoop:alphabeticalLabel'))
    'none',getString(message('RptgenSL:rsl_CAnnotationLoop:traversalOrderLabel'))
    },'alpha',getString(message('RptgenSL:rsl_CAnnotationLoop:sortLabel')),lic);


    p=rptgen.prop(h,'isFilterList','bool',false,...
    [getString(message('RptgenSL:rsl_CAnnotationLoop:searchForLabel')),':'],lic);






    p=rptgen.prop(h,'FilterTerms','MATLAB array',{'ClickFcn','.+'},...
    '',lic);




    p.Visible='off';




    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getLoopObjects'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
    });
