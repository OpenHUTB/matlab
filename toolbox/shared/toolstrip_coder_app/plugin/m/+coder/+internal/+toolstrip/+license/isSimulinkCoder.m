function[ret,msg]=isSimulinkCoder(~)


    msg='';
    ret=coder.internal.toolstrip.license.isMATLABCoder()&&...
    dig.isProductInstalled('Simulink Coder');
