function ret=isSerialPILEnabled




    ret=false;

    if ispref('MathWorks_Embedded_IDE_Link_PIL_Preferences','enableserial')
        val=getpref('MathWorks_Embedded_IDE_Link_PIL_Preferences','enableserial');
        ret=isequal(val,1);
    end
