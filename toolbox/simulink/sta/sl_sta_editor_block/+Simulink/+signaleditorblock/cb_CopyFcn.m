function cb_CopyFcn(blockPath)






    try
        set_param(blockPath,'ErrorFcn','Simulink.signaleditorblock.cb_ErrorFcn');
    catch
    end
end