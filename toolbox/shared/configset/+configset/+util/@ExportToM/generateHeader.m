function generateHeader(obj)






    if obj.config.format=="MATLAB function"&&obj.config.timestamp=="on"
        banner=[...
        '% ',message('Simulink:tools:MFileTimestamp',datestr(now)).getString,newline...
        ,'% ',message('Simulink:tools:MFileVersion',version()).getString,newline...
        ,newline];
    else
        banner='';
    end

    obj.buffer{end+1}=[banner,obj.config.varname,' = Simulink.ConfigSet;'];
