function schema




    pkg=findpackage('rptgen');

    h=schema.class(pkg,'crg_nest_set',pkg.findclass('rptcomponent'));


    rptgen.prop(h,'FileName','ustring','',...
    getString(message('rptgen:r_crg_nest_set:reportFilenameLabel')));


    rptgen.prop(h,'Inline','bool',true,...
    getString(message('rptgen:r_crg_nest_set:nestedReportIsInlineLabel')));


    rptgen.prop(h,'InsertFilename','bool',false,...
    getString(message('rptgen:r_crg_nest_set:insertLinkLabel')));



    rptgen.prop(h,'RelativeLink','bool',false,...
    getString(message('rptgen:r_crg_nest_set:useRelativeLinkLabel')));



    rptgen.prop(h,'IncrementFilename','bool',true,...
    getString(message('rptgen:r_crg_nest_set:incrementFilenameLabel')));



    rptgen.prop(h,'RecursionLimit','double',1,...
    getString(message('rptgen:r_crg_nest_set:recursionLimitLabel')));


    rptgen.prop(h,'FindAllFiles','bool',false,...
    getString(message('rptgen:r_crg_nest_set:nestAllLabel')));



    p=rptgen.prop(h,'RuntimeFileName','ustring','','',2);
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';


    p=rptgen.prop(h,'RuntimeNestedReport','handle',[],'',2);
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';





    rptgen.makeStaticMethods(h,{
    },{
    });
