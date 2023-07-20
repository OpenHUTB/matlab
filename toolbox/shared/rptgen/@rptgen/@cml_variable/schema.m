function schema






    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cml_variable',pkgRG.findclass('rpt_var_display'));


    p=rptgen.prop(h,'Source',{
    'W',getString(message('rptgen:r_cml_variable:baseWorkspaceLabel'))
    'M',getString(message('rptgen:r_cml_variable:matlabFileLabel'))
    'G',getString(message('rptgen:r_cml_variable:globalVariableLabel'))
    'direct',getString(message('rptgen:r_cml_variable:directLabel'))
    },'W',...
    getString(message('rptgen:r_cml_variable:variableLocationLabel')));

    p=rptgen.prop(h,'SourceDirect','MATLAB array',[],'');


    p=rptgen.prop(h,'Filename','ustring','matlab.mat',...
    getString(message('rptgen:r_cml_variable:filenameLabel')));


    p=rptgen.prop(h,'Variable','ustring','',...
    getString(message('rptgen:r_cml_variable:variableNameLabel')));


    rptgen.makeStaticMethods(h,{
    },{
'getDisplayName'
'getDisplayValue'
    });