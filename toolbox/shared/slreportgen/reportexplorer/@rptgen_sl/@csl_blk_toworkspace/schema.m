function schema






    pkg=findpackage('rptgen_sl');
    pkgHG=findpackage('rptgen_hg');

    h=schema.class(pkg,'csl_blk_toworkspace',pkgHG.findclass('AbstractFigSnap'));


    p=rptgen.prop(h,'TitleType',{
    'none',getString(message('RptgenSL:rsl_csl_blk_toworkspace:noneLabel'))
    'varname',getString(message('RptgenSL:rsl_csl_blk_toworkspace:variableLabel'))
    'blkname',getString(message('RptgenSL:rsl_csl_blk_toworkspace:blockNameLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_blk_toworkspace:customLabel'))
    },'varname',getString(message('RptgenSL:rsl_csl_blk_toworkspace:titleLabel')),'SIMULINK_Report_Gen');




    p=rptgen.prop(h,'CaptionType',{
    'none',getString(message('RptgenSL:rsl_csl_blk_toworkspace:noneLabel'))
    'auto',getString(message('RptgenSL:rsl_csl_blk_toworkspace:descriptionLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_blk_toworkspace:customLabel'))
    },'none',getString(message('RptgenSL:rsl_csl_blk_toworkspace:captionLabel')),'SIMULINK_Report_Gen');




    rptgen.makeStaticMethods(h,{
    },{
'gr_getCaption'
'gr_getTitle'
    });
