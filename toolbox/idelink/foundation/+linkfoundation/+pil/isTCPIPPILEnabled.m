function ret=isTCPIPPILEnabled




    ret=false;

    if ispref('MathWorks_Embedded_IDE_Link_PIL_Preferences','enabletcpip')
        val=getpref('MathWorks_Embedded_IDE_Link_PIL_Preferences','enabletcpip');
        ret=isequal(val,1);
    end
