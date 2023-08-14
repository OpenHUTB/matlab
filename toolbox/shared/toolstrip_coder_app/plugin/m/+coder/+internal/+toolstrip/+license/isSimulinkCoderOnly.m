function[ret,msg]=isSimulinkCoderOnly(~)


    msg='';
    ret=coder.internal.toolstrip.license.isSimulinkCoder()&&...
    ~dig.isProductInstalled('Embedded Coder');
