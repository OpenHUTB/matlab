function out=getStringForEncryptionCategory(category)




    switch category
    case 'SIM'
        out=DAStudio.message('Simulink:protectedModel:chkEncryptPasswordSim');
    case 'RTW'
        out=DAStudio.message('Simulink:protectedModel:chkEncryptPasswordCodeGeneration');
    case 'VIEW'
        out=DAStudio.message('Simulink:protectedModel:chkEncryptPasswordView');
    case 'MODIFY'
        out=DAStudio.message('Simulink:protectedModel:chkEncryptPasswordEdit');
    case 'HDL'
        out=DAStudio.message('Simulink:protectedModel:chkEncryptPasswordHDLCodeGeneration');
    end
end

