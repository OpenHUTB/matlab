function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cml_whos',pkgRG.findclass('rptcomponent'));


    p=rptgen.makeProp(h,'Source',{
    'WORKSPACE',getString(message('rptgen:r_cml_whos:baseWorkspaceLabel'))
    'MATFILE',getString(message('rptgen:r_cml_whos:matlabFileLabel'))
    'GLOBAL',getString(message('rptgen:r_cml_whos:globalWorkspaceLabel'))
    },'WORKSPACE',...
    getString(message('rptgen:r_cml_whos:variableSourceLabel')));


    p=rptgen.makeProp(h,'Filename','ustring','matlab.mat','');



    p=rptgen.makeProp(h,'TitleType',{
    'auto',getString(message('rptgen:r_cml_whos:autoLabel'))
    'manual',[getString(message('rptgen:r_cml_whos:customLabel')),': ']
    },'auto',...
    getString(message('rptgen:r_cml_whos:tableTitleLabel')));


    p=rptgen.makeProp(h,'TableTitle','ustring','Variables','');


    p=rptgen.makeProp(h,'isSize','bool',true,...
    getString(message('rptgen:r_cml_whos:variableDimensionsLabel')));


    p=rptgen.makeProp(h,'isBytes','bool',true,...
    getString(message('rptgen:r_cml_whos:variableBytesLabel')));


    p=rptgen.makeProp(h,'isClass','bool',true,...
    getString(message('rptgen:r_cml_whos:variableClassLabel')));


    p=rptgen.makeProp(h,'isValue','bool',false,...
    getString(message('rptgen:r_cml_whos:variableValueLabel')));


    rptgen.makeStaticMethods(h,{
    },{
    });
