function openDialog(obj,varargin)



    if matlab.system.isSystemObject(obj)
        hdg=matlab.system.ui.DialogGenerator('Platform','MATLAB');
        hdm=getDialogManager(hdg,obj);
        dlg=DAStudio.Dialog(hdm);
        dlg.show;
    else
        narginchk(2,2);
        paramSysObj=varargin{1};
        objExpr=get_param(obj,paramSysObj);%#ok<NASGU>
        hdm=matlab.system.ui.DynDialogManager('Simulink','DDG',obj);



        hdm.ActiveSystemObjectParameter=paramSysObj;

        hdm.getDialogSchema;

        dlg=DAStudio.Dialog(hdm);
        dlg.show;
    end