function schema






    pkg=findpackage('rptgen_sl');
    pkgHG=findpackage('rptgen_hg');

    h=schema.class(pkg,'csl_blk_scope',pkgHG.findclass('AbstractFigSnap'));


    p=rptgen.prop(h,'isForceOpen','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_scope:reportClosedScopesLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'CaptionType',{
    'none',getString(message('RptgenSL:rsl_csl_blk_scope:noneLabel'))
    'auto',getString(message('RptgenSL:rsl_csl_blk_scope:descriptionLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_blk_scope:customLabel'))
    },'none',getString(message('RptgenSL:rsl_csl_blk_scope:captionLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'TitleType',{
    'none',getString(message('RptgenSL:rsl_csl_blk_scope:noneLabel'))
    'blkname',getString(message('RptgenSL:rsl_csl_blk_scope:blockNameLabel'))
    'fullname',getString(message('RptgenSL:rsl_csl_blk_scope:fullBlockNameLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_blk_scope:customLabel'))
    },'blkname',getString(message('RptgenSL:rsl_csl_blk_scope:titleLabel')),'SIMULINK_Report_Gen');


    p=rptgen.prop(h,'AutoscaleScope','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_scope:autoTimeAxisLabel')),'SIMULINK_Report_Gen');


    rptgen.makeStaticMethods(h,{
    },{
'gr_getCaption'
'gr_getTitle'
    });
