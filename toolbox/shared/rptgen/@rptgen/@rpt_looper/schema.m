function schema




    pkg=findpackage('rptgen');

    h=schema.class(pkg,'rpt_looper',pkg.findclass('rpt_section'));

    rptgen.prop(h,'ObjectSection','bool',false,...
    getString(message('rptgen:r_rpt_looper:sectionPerLoopLabel')));

    rptgen.prop(h,'ShowTypeInTitle','bool',false,...
    getString(message('rptgen:r_rpt_looper:objectTypeInTitleLabel')));

    rptgen.prop(h,'ObjectAnchor','bool',false,...
    getString(message('rptgen:r_rpt_looper:anchorPerObjectLabel')));


    rptgen.prop(h,'RuntimeLoopObjects','MATLAB array',[],'',2);


    rptgen.prop(h,'RuntimeCurrentObject','MATLAB array',[],'',2);


    p=rptgen.prop(h,'RuntimeCleanupFcns','MATLAB array',{},'Cell array of cleanup functions',2);
    p.Visible='off';



    rptgen.makeStaticMethods(h,{
'loop_getDescription'
    },{
'getSectionType'
'loop_getDialogSchema'
'loop_getContextString'
'loop_getLoopObjects'
'loop_getObjectLinkID'
'loop_getObjectName'
'loop_getObjectType'
'loop_getPropSrc'
'loop_restoreState'
'loop_saveState'
'loop_setState'
'loop_makeSection'
'loop_closeSection'
'mcodeConstructor'
'dlgSectionOptions'
    });
