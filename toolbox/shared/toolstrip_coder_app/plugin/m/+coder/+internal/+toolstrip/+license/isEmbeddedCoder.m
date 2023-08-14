function[ret,msg]=isEmbeddedCoder(~)


    msg='';
    ret=coder.internal.toolstrip.license.isSimulinkCoder()&&...
    dig.isProductInstalled('Embedded Coder');


