function[result,msg]=isSimulinkCompilerInstalledAndLicensed(~)



    result=dig.isProductInstalled('Simulink Compiler');
    msg='';
end


