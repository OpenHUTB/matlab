function schema













    pkg=findpackage('RptSldv');



    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'LoopIndexedTable',pkgRG.findclass('cfr_table'));

    rptgen.makeStaticMethods(h,{
    },{
'execute'
'getContent'
'listLoopObjects'
'getCurrLoopIdx'
'getIdxValue'

    });
