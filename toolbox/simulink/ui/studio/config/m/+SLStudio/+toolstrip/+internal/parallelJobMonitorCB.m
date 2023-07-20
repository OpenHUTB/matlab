



function parallelJobMonitorCB(cbinfo)
    msg='New UI being built, not shipped yet (g1556636)';
    disp(msg);
    beep;
    dp=DAStudio.DialogProvider;
    dp.msgbox(msg,'Simulink Toolstrip');
end
