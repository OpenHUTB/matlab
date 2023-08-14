function checkLicense(checkout)





    if nargin<1

        checkout=true;
    end

    [hdlcL,hdlcLMsg]=builtin('license','checkout','Simulink_HDL_Coder');
    [mlcL,mlcLMsg]=builtin('license','checkout','MATLAB_Coder');

    licenseAvailable=hdlcL&&mlcL;

    if checkout&&~licenseAvailable

        lReason=[hdlcLMsg,newline,mlcLMsg];
        error(message('hdlcoder:engine:nolicenseavailablewithreason',lReason));
    end

    if~hdlcoderui.isslhdlcinstalled


        error(message('hdlcoder:engine:nolicenseavailable'));
    end


    if~license('test','Fixed_Point_Toolbox')
        error(message('hdlcoder:engine:nofxplicenseavailable'));
    end


    fi('DataType','double');

end


