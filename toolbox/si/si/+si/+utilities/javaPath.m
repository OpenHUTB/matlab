function javaPath=javaPath()

    try
        javaPath=string(java.lang.System.getProperty("java.home"));
    catch ignored %#ok<NASGU> 
        javaPath=string.empty(0,1);
    end
end

