function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'rpt_importer',pkgRG.findclass('rptcomponent'));


    p=rptgen.makeProp(h,'ImportType',{
    'text',getString(message('rptgen:r_rpt_importer:plainTextLabel'))
    'para-lb',getString(message('rptgen:r_rpt_importer:lineBreakParagraphsLabel'))
    'para-emptyrow',getString(message('rptgen:r_rpt_importer:emptyRowParagraphsLabel'))
    'honorspaces',getString(message('rptgen:r_rpt_importer:preserveWhitespaceLabel'))
    'fixedwidth',getString(message('rptgen:r_rpt_importer:fixedWidthLabel'))
    'docbook',getString(message('rptgen:r_rpt_importer:docbookLabel'))
    'external',getString(message('rptgen:r_rpt_importer:formattedTextLabel'))
    'code_highlighted',getString(message('rptgen:r_rpt_importer:syntaxHighlightedLabel'))},...
    'honorspaces',...
    getString(message('rptgen:r_rpt_importer:importAsLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'importFile'
    });
