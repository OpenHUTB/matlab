function[r,msg]=isHDLVerifierAvailable(~)



    persistent hdlVerifierInstalled;
    if isempty(hdlVerifierInstalled)
        hdlVerifierInstalled=~isempty(ver('hdlverifier'))&&license('test','EDA_Simulator_Link');
    end
    r=hdlVerifierInstalled;
    msg='';
