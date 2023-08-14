function header=getDisplayHeader(systemName)


    header=feval([systemName,'.getHeaderImpl']);
    if strcmp(header,'default')
        header=matlab.system.display.Header(systemName);
    end
    validateattributes(header,{'matlab.system.display.Header'},{'scalar'},'getHeaderImpl','output');
end
