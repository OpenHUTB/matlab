function schema






    pkg=findpackage('rptgen_hg');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'chg_property',pkgRG.findclass('rpt_var_display'));

    p=rptgen.makeProp(h,'ObjectType',{
    'Figure','Figure'
    'Axes','Axes'
    'Object','Object'
    },'Figure',...
    getString(message('rptgen:rh_chg_property:useCurrentLabel')));

    p=rptgen.makeProp(h,'FigureProperty',rptgen.makeStringType,'Name',...
    getString(message('rptgen:rh_chg_property:figurePropertyLabel')));

    p=rptgen.makeProp(h,'AxesProperty',rptgen.makeStringType,'Title',...
    getString(message('rptgen:rh_chg_property:axesPropertyLabel')));

    p=rptgen.makeProp(h,'ObjectProperty',rptgen.makeStringType,'Tag',...
    getString(message('rptgen:rh_chg_property:objectPropertyLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'getDisplayName'
'getDisplayValue'
    });