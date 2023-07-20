function[status,msg]=setDialogProperties(h,dlg)
    status=true;
    msg='';
    execMode=dlg.getWidgetValue('ExecutionMode');
    switch(execMode)
    case 0
        h.ExecutionMode='Auto';
    case 1
        h.ExecutionMode='Off';
    case 2
        h.ExecutionMode='On';
    end







