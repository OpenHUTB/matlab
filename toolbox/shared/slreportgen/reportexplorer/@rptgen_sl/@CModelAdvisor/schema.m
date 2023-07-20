function schema

















    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'CModelAdvisor',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'ReuseReport','bool',true,...
    getString(message('RptgenSL:rsl_CModelAdvisor:useExistingReport')));

    rptgen.makeStaticMethods(h,{
    },{
    });
