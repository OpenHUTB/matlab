function schema






    pkgUD=findpackage('rptgen_ud');

    h=schema.class(pkgUD,'cud_prop_loop',pkgUD.findclass('udd_loop'));


    p=rptgen.prop(h,'LoopType',{
    'auto',getString(message('rptgen:ru_cud_prop_loop:autoLabel'))
    'manual',getString(message('rptgen:ru_cud_prop_loop:manualLabel'))
    },'auto',...
    getString(message('rptgen:ru_cud_prop_loop:showPropertiesOfCurrentLabel')));


    p=rptgen.prop(h,'ReportedProperties','string vector',{},'');

    p=rptgen.prop(h,'UddType',rptgen_ud.enumObjectTypeAuto,'auto',...
    getString(message('rptgen:ru_cud_prop_loop:currentPropertiesLabel')));


    p=rptgen.prop(h,'LocalPropertiesOnly','bool',false,...
    getString(message('rptgen:ru_cud_prop_loop:noInheritedLabel')));






    p=rptgen.prop(h,'VisibleOnly','bool',logical(1),...
    getString(message('rptgen:ru_cud_prop_loop:visibleOnlyLabel')));

    p=rptgen.prop(h,'PublicGetOnly','bool',logical(1),...
    getString(message('rptgen:ru_cud_prop_loop:publicGettableOnlyLabel')));

    p=rptgen.prop(h,'PublicSetOnly','bool',logical(0),...
    getString(message('rptgen:ru_cud_prop_loop:publicOnlyLabel')));

    p=rptgen.prop(h,'SerializableOnly','bool',logical(0),...
    getString(message('rptgen:ru_cud_prop_loop:serializableOnlyLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'loop_getContextString'
'loop_getDialogSchema'
'loop_getLoopObjects'
'loop_getPropSrc'
    });