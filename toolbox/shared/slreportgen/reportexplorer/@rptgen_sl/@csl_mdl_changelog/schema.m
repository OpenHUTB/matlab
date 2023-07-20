function schema






    pkg=findpackage('rptgen_sl');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'csl_mdl_changelog',pkgRG.findclass('rptcomponent'));

    lic='SIMULINK_Report_Gen';


    p=rptgen.prop(h,'isAuthor','bool',false,...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:authorNameLabel')),lic);


    p=rptgen.prop(h,'isVersion','bool',false,...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:versionLabel')),lic);


    p=rptgen.prop(h,'isDate','bool',true,...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:dateChangedLabel')),lic);


    p=rptgen.prop(h,'isComment','bool',true,...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:changeDescriptionLabel')),lic);


    p=rptgen.prop(h,'isLimitRevisions','bool',false,...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:limitRevisionsLabel')),lic);


    p=rptgen.prop(h,'NumRevisions','int32',12,...
    '',lic);


    p=rptgen.prop(h,'isLimitDate','bool',false,...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:revisionsSinceLabel')),lic);


    p=rptgen.prop(h,'DateLimit',rptgen.makeStringType,...
    '%<datestr(now-14)>',...
    '',lic);


    p=rptgen.prop(h,'TableTitle',rptgen.makeStringType,...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:modelHistoryLabel')),...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:tableTitleLabel')),lic);


    p=rptgen.makeProp(h,'DateFormat','ustring','inherit',...
    getString(message('RptgenSL:rsl_csl_mdl_changelog:dateFormatLabel')),lic);


    p=rptgen.makeProp(h,'SortOrder',{
    'chronological',getString(message('RptgenSL:rsl_csl_mdl_changelog:oldestToNewestLabel'))
    'reversechronological',getString(message('RptgenSL:rsl_csl_mdl_changelog:newestToOldestLabel'))
    },'reversechronological',getString(message('RptgenSL:rsl_csl_mdl_changelog:sortOrderLabel')),lic);




    p=rptgen.prop(h,'isBorder','bool',true,'',lic);
    p.Visible='off';






    rptgen.makeStaticMethods(h,{
    },{
'parseHistory'
    });
