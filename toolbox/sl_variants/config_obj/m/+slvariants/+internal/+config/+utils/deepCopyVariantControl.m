function varCtrlDup=deepCopyVariantControl(varCtrl)







    varCtrlDup=varCtrl;
    if isa(varCtrl.Value,'Simulink.Parameter')



        varCtrlDup.Value=copy(varCtrl.Value);
    end
end
