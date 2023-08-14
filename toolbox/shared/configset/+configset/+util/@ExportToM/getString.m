function str=getString(obj)


    str=strjoin(obj.buffer,'\n\n');

    if strcmp(obj.config.format,'MATLAB function')
        [~,funcName,~]=fileparts(obj.name);
        str=sprintf('%s\n%s',...
        ['function ',obj.config.varname,' = ',funcName,'()'],...
        str);
    end

