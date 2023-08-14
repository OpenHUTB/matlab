function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cfr_html_text',pkgRG.findclass('rptcomponent'));




    rptgen.makeProp(h,'SourceType',{
    'string',getString(message('rptgen:r_cfr_html_text:stringLabel'))
    'file',getString(message('rptgen:r_cfr_html_text:fileLabel'))
    'workspaceVariable',getString(message('rptgen:r_cfr_html_text:workspaceVariableLabel'))
    },'string',...
    getString(message('rptgen:r_cfr_html_text:sourceTypeLabel')));


    rptgen.prop(h,'HTMLString','ustring','',...
    getString(message('rptgen:r_cfr_html_text:HTMLStringLabel')));


    rptgen.prop(h,'FileName','ustring','',...
    getString(message('rptgen:r_cfr_html_text:fileNameLabel')));


    rptgen.prop(h,'WorkspaceVariable','ustring','',...
    getString(message('rptgen:r_cfr_html_text:workspaceVariableNameLabel')));


    rptgen.makeStaticMethods(h,{},{});