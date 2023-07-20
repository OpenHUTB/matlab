function schema






    pkgUD=findpackage('rptgen_ud');

    h=schema.class(pkgUD,'cud_obj_loop',pkgUD.findclass('udd_loop'));



    p=rptgen.prop(h,'ObjectSource',{
    'workspace',getString(message('rptgen:ru_cud_obj_loop:workspaceObjectsLabel'))
    'matfile',getString(message('rptgen:ru_cud_obj_loop:matFileObjectsLabel'))
    'loopchild',getString(message('rptgen:ru_cud_obj_loop:currentChildrenLabel'))
    'direct',getString(message('rptgen:ru_cud_obj_loop:directObjectsLabel'))
    },'workspace',...
    getString(message('rptgen:ru_cud_obj_loop:loopEnabledLabel')));


    p=rptgen.prop(h,'Filename',rptgen.makeStringType,'matlab.mat',...
    getString(message('rptgen:ru_cud_obj_loop:matFileLabel')));


    p=rptgen.prop(h,'RuntimeCurrentObject','handle vector',[],...
    getString(message('rptgen:ru_cud_obj_loop:searchWhenChildOrDirect')));






    p=rptgen.prop(h,'NameList','string vector',{},...
    getString(message('rptgen:ru_cud_obj_loop:includeVariablesLabel')));



    p=rptgen.prop(h,'ExcludeRoot','bool',logical(1),...
    getString(message('rptgen:ru_cud_obj_loop:excludeCurrentLabel')));



    p=rptgen.prop(h,'FindArguments','string vector',{},...
    getString(message('rptgen:ru_cud_obj_loop:searchTermsLabel')));




    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getDialogSchema'
'loop_getLoopObjects'
'loop_getPropSrc'
    });