function ret=getServerHostName




    ret='localhost';

    if ispref('MathWorks_Embedded_IDE_Link_PIL_Preferences','servername')
        ret=getpref('MathWorks_Embedded_IDE_Link_PIL_Preferences','servername');
    end
