function schema






    pkg=findpackage('rptgen_sl');
    pkgHG=findpackage('rptgen_hg');

    h=schema.class(pkg,'csl_blk_lookup',pkgHG.findclass('AbstractFigSnap'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'isSinglePlot','bool',true,...
    getString(message('RptgenSL:rsl_csl_blk_lookup:plotOneDDataLabel')),lic);


    p=rptgen.prop(h,'SinglePlotType',{
    'lineplot',getString(message('RptgenSL:rsl_csl_blk_lookup:linePlotLabel'))
    'barplot',getString(message('RptgenSL:rsl_csl_blk_lookup:barPlotLabel'))
    },'lineplot','',lic);


    p=rptgen.prop(h,'isSingleTable','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_lookup:createForOneDLabel')),lic);


    p=rptgen.prop(h,'isDoublePlot','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_lookup:plotTwoDDataLabel')));


    p=rptgen.prop(h,'DoublePlotType',{
    'multilineplot',getString(message('RptgenSL:rsl_csl_blk_lookup:multiLinePlotLabel'))
    'surfaceplot',getString(message('RptgenSL:rsl_csl_blk_lookup:surfacePlotLabel'))
    },'surfaceplot','',lic);


    p=rptgen.prop(h,'isDoubleTable','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_lookup:createForTwoDLabel')),lic);


    p=rptgen.prop(h,'isMultiTable','bool',false,...
    getString(message('RptgenSL:rsl_csl_blk_lookup:createForNDLabel')),lic);


    p=rptgen.prop(h,'TitleType',{
    'none',getString(message('RptgenSL:rsl_csl_blk_lookup:noneLabel'))
    'auto',getString(message('RptgenSL:rsl_csl_blk_lookup:blockNameLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_blk_lookup:customLabel'))
    },'none',getString(message('RptgenSL:rsl_csl_blk_lookup:titleLabel')),lic);


    p=rptgen.prop(h,'CaptionType',{
    'none',getString(message('RptgenSL:rsl_csl_blk_lookup:noneLabel'))
    'auto',getString(message('RptgenSL:rsl_csl_blk_lookup:descriptionLabel'))
    'manual',getString(message('RptgenSL:rsl_csl_blk_lookup:customLabel'))
    },'none',getString(message('RptgenSL:rsl_csl_blk_lookup:captionLabel')),lic);


    rptgen.makeStaticMethods(h,{
    },{
'gr_getCaption'
'gr_getTitle'
'makeFigureOneD'
'makeFigureTwoD'
    });
