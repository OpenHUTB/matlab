function b=hasPLCCoderLicense()


    b=false;
    if builtin('license','checkout','MATLAB_Coder')&&...
        builtin('license','checkout','Simulink_PLC_Coder')
        b=true;
    end

end