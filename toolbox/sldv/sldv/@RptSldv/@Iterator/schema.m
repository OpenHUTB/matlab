function schema













    pkg=findpackage('RptSldv');



    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'Iterator',pkgRG.findclass('rpt_looper'));

    p=rptgen.prop(h,'SectionTitle',rptgen.makeStringType,'',...
    getString(message('Sldv:RptSldv:Iterator:schema:SectionTitle')));

    rptgen.makeStaticMethods(h,{
    },{
'getDialogSchema'
'execute'
'loop_setState'
'loop_getObjectName'
'loop_getObjectLinkID'
'loop_getObjectType'
'getSectionTitle'
    });
