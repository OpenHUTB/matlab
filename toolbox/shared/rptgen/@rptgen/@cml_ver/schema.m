function schema






    pkg=findpackage('rptgen');

    h=schema.class(pkg,'cml_ver',pkg.findclass('rptcomponent'));


    rptgen.prop(h,'isVersion','bool',true,...
    getString(message('rptgen:r_cml_ver:versionNumberLabel')));


    rptgen.prop(h,'isRelease','bool',true,...
    getString(message('rptgen:r_cml_ver:releaseNumberLabel')));


    rptgen.prop(h,'isDate','bool',true,...
    getString(message('rptgen:r_cml_ver:releaseDateLabel')));


    rptgen.prop(h,'isRequired','bool',true,getString(message('rptgen:r_cml_ver:isRequiredLabel')));


    rptgen.prop(h,'showOnlyRequired','bool',false,...
    getString(message('rptgen:r_cml_ver:showOnlyRequiredLabel')));


    rptgen.prop(h,'TableTitle','ustring',getString(message('rptgen:r_cml_ver:versionNumberLabel')),...
    getString(message('rptgen:r_cml_ver:tableTitleLabel')));


    rptgen.prop(h,'isHeaderRow','bool',true,...
    getString(message('rptgen:r_cml_ver:showHeaderRowLabel')));


    p=rptgen.prop(h,'isBorder','bool',true,...
    getString(message('rptgen:r_cml_ver:showBorderLabel')));
    p.AccessFlags.PublicGet='off';


    rptgen.makeStaticMethods(h,{
    },{
    });