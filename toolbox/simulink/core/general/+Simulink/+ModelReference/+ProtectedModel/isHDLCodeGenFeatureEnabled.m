function[result]=isHDLCodeGenFeatureEnabled()






    result=false;
    if~slfeature('ProtectedModelWithGeneratedHDLCode')
        result=false;
    elseif dig.isProductInstalled('HDL Coder')
        result=true;
    end
end
