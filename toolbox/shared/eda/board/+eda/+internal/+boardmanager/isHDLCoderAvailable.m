function r=isHDLCoderAvailable

    persistent isAvailable;

    if isempty(isAvailable)
        isAvailable=~isempty(ver('hdlcoder'));
        isAvailable=isAvailable&&license('test','Simulink_HDL_Coder');
    end

    r=isAvailable;

