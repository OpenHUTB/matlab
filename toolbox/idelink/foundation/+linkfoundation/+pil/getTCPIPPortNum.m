function ret=getTCPIPPortNum




    ret=17725;

    if ispref('MathWorks_Embedded_IDE_Link_PIL_Preferences','portnum')
        val=getpref('MathWorks_Embedded_IDE_Link_PIL_Preferences','portnum');
        if isnumeric(val)
            ret=int16(val);
        end
    end
