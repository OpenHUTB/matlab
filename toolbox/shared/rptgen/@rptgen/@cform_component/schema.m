function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cform_component',pkgRG.findclass('rptcomponent'));


    rptgen.makeStaticMethods(h,{
'updateTemplateInfo'
'updateHoleInfo'
'updatePageLayoutInfo'
'getReportForm'
'getParentFormComponent'
'getParentSubform'
'updateInnerHoles'
'updateInnerPageLayout'
'updateInnerHeaderFooter'
'broadcastDirty'
'hasParentHoleDefaultStyleName'
'getParentHoleDefaultStyleName'
    },{});