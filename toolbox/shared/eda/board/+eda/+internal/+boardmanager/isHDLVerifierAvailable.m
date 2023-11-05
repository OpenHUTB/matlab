function[r,msg]=isHDLVerifierAvailable(~)

    persistent isAvailable;

    if isempty(isAvailable)
        isAvailable=~isempty(ver('hdlverifier'));
        isAvailable=isAvailable&&license('test','EDA_Simulator_Link');
    end

    r=isAvailable;
    msg='';

