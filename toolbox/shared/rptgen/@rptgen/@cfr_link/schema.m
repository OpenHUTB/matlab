function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cfr_link',pkgRG.findclass('rptcomponent'));


    rptgen.makeProp(h,'LinkType',{
    'anchor',getString(message('rptgen:r_cfr_link:anchorLabel'))
    'link',getString(message('rptgen:r_cfr_link:internalLinkLabel'))
    'ulink',getString(message('rptgen:r_cfr_link:externalLinkLabel'))
    },'link',...
    getString(message('rptgen:r_cfr_link:linkTypeLabel')));


    rptgen.makeProp(h,'LinkID','ustring','',...
    getString(message('rptgen:r_cfr_link:linkIdentifierLabel')));


    rptgen.makeProp(h,'LinkText','ustring','',...
    getString(message('rptgen:r_cfr_link:linkTextLabel')));


    rptgen.makeProp(h,'isEmphasizeText','bool',false,...
    getString(message('rptgen:r_cfr_link:emphasizeLabel')));


    rptgen.makeStaticMethods(h,{},{});