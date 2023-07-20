function[value,msg]=isHDLCoderInstalledAndLicensed(~)
    value=hdlcoderui.isslhdlcinstalled&&license('test','Simulink_HDL_Coder');
    msg='';
end