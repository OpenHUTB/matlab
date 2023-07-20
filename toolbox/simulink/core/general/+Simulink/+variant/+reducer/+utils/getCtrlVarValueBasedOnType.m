
function cvv=getCtrlVarValueBasedOnType(cvv)





    if Simulink.variant.manager.configutils.isScalarParameterObj(cvv)||...
        Simulink.variant.manager.configutils.isScalarVariantControlObj(cvv)


        cvv=[cvv.Value];
        cvv=cvv(:)';
    end
end
