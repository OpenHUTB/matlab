function[status,dscr]=HDL_status(cs,~)


    dscr='';
    cs=cs.getConfigSet;
    hdl=cs.getComponent('HDL Coder');


    if isempty(hdl)...
        ||~hdl.hdlinstalled...
        ||isempty(hdl.CLI)...
        ||isempty(cs.getModel)

        status=configset.internal.data.ParamStatus.UnAvailable;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end
