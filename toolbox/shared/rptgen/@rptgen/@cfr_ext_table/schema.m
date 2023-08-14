function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'cfr_ext_table',pkgRG.findclass('rptcomponent'));


    rptgen.prop(h,'TableTitle','ustring','',...
    getString(message('rptgen:r_cfr_ext_table:tableTitleLabel')));



    label=getString(message('rptgen:r_cfr_ext_table:tableTitleStyleNameLabel'));
    rptgen.makeProp(h,'TitleStyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',label);

    rptgen.prop(h,'TitleStyleName','ustring','');



    label=getString(message('rptgen:r_cfr_ext_table:tableStyleNameLabel'));
    rptgen.makeProp(h,'TableStyleNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',label);


    rptgen.prop(h,'TableStyleName','ustring','rgUnruledTable');


    rptgen.prop(h,'IsPgwide','bool',true,getString(message('rptgen:r_cfr_ext_table:tableSpansPageLabel')));


    rptgen.makeProp(h,'TableWidthType',{
    'auto',getString(message('rptgen:r_cfr_ext_table:autoTableWidthLabel'))
    'specify',getString(message('rptgen:r_cfr_ext_table:specifyTableWidthLabel'))
    },'auto','');


    rptgen.prop(h,'TableWidth','ustring','100%',getString(message('rptgen:r_cfr_ext_table:tableWidthLabel')));


    rptgen.prop(h,'NumCols','ustring','2',getString(message('rptgen:r_cfr_ext_table:numColsLabel')));


    rptgen.prop(h,'HorizAlign',rptgen.enumTableHorizAlign,'left',...
    getString(message('rptgen:r_cfr_ext_table:horizAlignLabel')));


    rptgen.prop(h,'Frame',rptgen.enumTableFrame,'all',getString(message('rptgen:r_cfr_ext_table:frameLabel')));


    rptgen.prop(h,'HasColSep','bool',true,getString(message('rptgen:r_cfr_ext_table:hasColSepLabel')));


    rptgen.prop(h,'HasRowSep','bool',true,getString(message('rptgen:r_cfr_ext_table:hasRowSepLabel')));


    rptgen.prop(h,'OrientLandscape','bool',false,...
    getString(message('rptgen:r_cfr_ext_table:rotate90Label')));


    rptgen.makeProp(h,'IndentNameType',{
    'auto',getString(message('rptgen:r_cfr_text:autoLabel'))
    'custom',getString(message('rptgen:r_cfr_text:customLabel'))
    },'auto',getString(message('rptgen:r_cfr_ext_table:indentLabel')));

    rptgen.prop(h,'Indent','ustring','');


    rptgen.makeStaticMethods(h,{
    },{
    });
