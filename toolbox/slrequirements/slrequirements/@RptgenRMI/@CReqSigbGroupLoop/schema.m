function schema






    pkg=findpackage('RptgenRMI');
    pkgRG=findpackage('RptSldvShared');
    this=schema.class(pkg,'CReqSigbGroupLoop',pkgRG.findclass('SigbGroupLoop'));


    rptgen.makeStaticMethods(this,{
    },{
    });
