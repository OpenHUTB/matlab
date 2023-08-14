function schema
















    pkg=findpackage('RptSldvShared');

    pkgRG=findpackage('rptgen_hg');


    h=schema.class(pkg,'SigbGroupLoop',pkgRG.findclass('chg_fig_loop'));


    rptgen.prop(h,'LoopType',{
    'auto',getString(message('Sldv:RptSldv:Sigb:schema:CollectAllSignalBuilders'))
    'list',getString(message('Sldv:RptSldv:Sigb:schema:CustomUseList'))
    },'auto',getString(message('Sldv:RptSldv:Sigb:schema:LoopOnSignalGroupsInSystems')));


    rptgen.prop(h,'ObjectList','string vector',{'gcs'},...
    '');

    rptgen.makeStaticMethods(h,{
    },{
'loop_getLoopObjects'
    });