function schema






    lic='MATLAB_Report_Gen';

    msg=@(key)getString(message(['rptgen:rpt_var_display:',key]));

    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'rpt_var_display',...
    pkgRG.findclass('rptcomponent'));





    rptgen.prop(h,'SizeLimit','int32',32,...
    msg('WdgtLblArraySizeLmt'));





    rptgen.prop(h,'DepthLimit','int32',10,msg('WdgtLblDepthLmt'));

    rptgen.prop(h,'ObjectLimit','int32',200,msg('WdgtLblObjLmt'));



    rptgen.makeProp(h,'DisplayTable',{
    'table',msg('WdgtValDispTblTable')
    'para',msg('WdgtValDispTblPara')
    'text',msg('WdgtValDispTblText')
    'auto',msg('WdgtValDispTblAuto')
    },'auto',...
    msg('WdgtLblDispTbl'));


    rptgen.makeProp(h,'TitleMode',{
    'none',msg('WdgtValTitleModeNone')
    'auto',msg('WdgtValTitleModeAuto')
    'manual',msg('WdgtValTitleModeManual')
    },'auto',...
    msg('WdgtLblTitleMode'));

    rptgen.makeProp(h,'CustomTitle','ustring','',...
    msg('WdgtLblCustomTitle'));

    rptgen.makeProp(h,'IgnoreIfEmpty','bool',false,...
    msg('WdgtLblIgnIfEmpty'));

    rptgen.prop(h,'IgnoreIfDefault','bool',false,...
    msg('WdgtLblIgnIfDef'),lic);

    rptgen.prop(h,'ShowTypeInHeading','bool',false,...
    msg('WdgtLblShowTypeInHead'),lic);

    rptgen.prop(h,'ShowTableGrids','bool',true,...
    msg('WdgtLblShowGrids'),lic);

    rptgen.prop(h,'MakeTablePageWide','bool',false,...
    msg('WdgtLblPgWide'),lic);

    rptgen.prop(h,'PropertyFilterCode','ustring',msg('PropertyFilterCodeDefault'),...
    msg('PropertyFilterCodeLabel'));

    m=schema.method(h,'msg','Static');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'ustring'};
    s.OutputTypes={'ustring'};







    rptgen.makeStaticMethods(h,{
    },{
'vdGetDialogSchema'
'getDisplayName'
'getDisplayValue'
    });
