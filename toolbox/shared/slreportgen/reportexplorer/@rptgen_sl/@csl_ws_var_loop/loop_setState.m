function ok=loop_setState(~,currentObject,~)






    adSL=rptgen_sl.appdata_sl;
    adSL.CurrentWorkspaceVar=currentObject;
    adSL.Context='WorkspaceVar';
    ok=true;
