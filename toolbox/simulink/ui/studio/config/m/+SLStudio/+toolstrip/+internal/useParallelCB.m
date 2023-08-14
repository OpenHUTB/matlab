



function useParallelCB(cbinfo)
    msg='Currently only scripts are supported for parallel command (g1556636)';
    disp(msg);
    beep;
    dp=DAStudio.DialogProvider;
    dp.msgbox(msg,'Simulink Toolstrip');
end
