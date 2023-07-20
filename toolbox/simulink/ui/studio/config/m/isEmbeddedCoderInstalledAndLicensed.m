function[value,msg]=isEmbeddedCoderInstalledAndLicensed(~)





    value=dig.isProductInstalled('Simulink Coder')&&...
    dig.isProductInstalled('Embedded Coder');
    msg='';

end
