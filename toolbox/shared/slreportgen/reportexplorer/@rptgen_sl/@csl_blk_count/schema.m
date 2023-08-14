function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_blk_count',pkgRG.findclass('rptcomponent'));


    p=rptgen.prop(h,'IncludeBlocks',{
    'all',getString(message('RptgenSL:rsl_csl_blk_count:allBlocksInModelLabel'))
    'reported',getString(message('RptgenSL:rsl_csl_blk_count:allBlocksInReportedSystemsLabel'))
    },'all','','SIMULINK_Report_Gen');


    p=rptgen.prop(h,'TableTitle',rptgen.makeStringType,getString(message('RptgenSL:rsl_csl_blk_count:blockTypeCountLabel')),...
    getString(message('RptgenSL:rsl_csl_blk_count:tableTitleLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'isBlockName','bool',true,...
    getString(message('RptgenSL:rsl_csl_blk_count:showBlockNamesLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'SortOrder',{
    'alpha',getString(message('RptgenSL:rsl_csl_blk_count:alphabeticallyByBlockTypeLabel'))
    'numblocks',getString(message('RptgenSL:rsl_csl_blk_count:byNumberOfBlocksLabel'))
    },'alpha',getString(message('RptgenSL:rsl_csl_blk_count:sortTableLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'IncludeTotal','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_count:showTotalCountLabel')),'SIMULINK_Report_Gen');



    rptgen.makeStaticMethods(h,{
    },{
    });
