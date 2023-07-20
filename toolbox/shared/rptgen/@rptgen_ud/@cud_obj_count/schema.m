function schema









    pkgUD=findpackage('rptgen_ud');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkgUD,'cud_obj_count',pkgRG.findclass('rptcomponent'));


    p=rptgen.makeProp(h,'ShowObjects','bool',logical(1),...
    getString(message('rptgen:ru_cud_obj_count:includeAllText')));


    p=rptgen.makeProp(h,'SortBy',{
    'name',getString(message('rptgen:ru_cud_obj_count:sortAlphaLabel'))
    'count',getString(message('rptgen:ru_cud_obj_count:sortDecreasingLabel'))
    },'count',...
    getString(message('rptgen:ru_cud_obj_count:sortResultsLabel')));


    p=rptgen.makeProp(h,'CountDepth',{
    'shallow',getString(message('rptgen:ru_cud_obj_count:noDepthLabel'))
    'deep',getString(message('rptgen:ru_cud_obj_count:allDescendantsLabel'))
    },'shallow',...
    getString(message('rptgen:ru_cud_obj_count:searchDeepLabel')));


    p=rptgen.prop(h,'IncludeTotal','bool',false,...
    getString(message('rptgen:ru_cud_obj_count:showTotalLabel')));



    rptgen.makeStaticMethods(h,{
    },{
'count_getChildObjects'
'count_getObjectClass'
'count_getObjectType'
'count_getPropsrc'
'count_getRootObject'
'count_getTitle'
    });