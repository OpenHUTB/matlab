function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_blk_doc',pkgRG.findclass('rptcomponent'));









    p=rptgen.prop(h,'ImportType',{
    'text',getString(message('RptgenSL:rsl_csl_blk_doc:plainTextLabel'))
    'para-lb',getString(message('RptgenSL:rsl_csl_blk_doc:paragraphsAreLineBreaksLabel'))
    'para-emptyrow',getString(message('RptgenSL:rsl_csl_blk_doc:paragraphsAreEmptyRowsLabel'))
    'honorspaces',getString(message('RptgenSL:rsl_csl_blk_doc:textLabel'))
    'fixedwidth',getString(message('RptgenSL:rsl_csl_blk_doc:fixedWidthTextLabel'))
    },'honorspaces',getString(message('RptgenSL:rsl_csl_blk_doc:importAsLabel')),'SIMULINK_Report_Gen');

    p=rptgen.prop(h,'LinkingAnchor','bool',true,...
    getString(message('RptgenSL:rsl_csl_blk_doc:insertBlockAnchorLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'ConvertHTML','bool',true,...
    getString(message('RptgenSL:rsl_csl_blk_doc:convertHTML')),'SIMULINK_Report_Gen');

    p=rptgen.prop(h,'EmbedFile','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_doc:embedFile')),'SIMULINK_Report_Gen');



    rptgen.makeStaticMethods(h,{
    },{
    });
