function[hObj,hSrc,hDlg,model]=populateTLCFunctionArguments(cs,dlg)





    hObj=cs;
    hSrc=cs;
    hDlg=dlg;

    mdlH=cs.getModel;
    if isempty(mdlH)
        model='';
    else
        model=get_param(mdlH,'Name');
    end
