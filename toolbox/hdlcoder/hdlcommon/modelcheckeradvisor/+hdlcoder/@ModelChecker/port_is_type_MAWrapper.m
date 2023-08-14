function isType=port_is_type_MAWrapper(block,IO,portNumber,isTypeFcnHandle)







    portTypes=get_param(block,'CompiledPortDataTypes');
    if strcmpi(IO,'input')
        try
            isType=isTypeFcnHandle(eval([portTypes.Inport{portNumber},'(0)']));
        catch me
            if strcmp(me.identifier,'MATLAB:UndefinedFunction')
                isType=false;
            elseif strcmp(me.identifier,'MATLAB:class:InvalidEnum')
                if isequal(isTypeFcnHandle,@isenum)
                    isType=true;
                else
                    isType=false;
                end
            else
                error('Invalid port number');
            end
        end
    elseif strcmpi(IO,'output')
        try
            isType=isTypeFcnHandle(eval([portTypes.Outport{portNumber},'(0)']));
        catch me
            if strcmp(me.identifier,'MATLAB:UndefinedFunction')
                isType=false;
            elseif strcmp(me.identifier,'MATLAB:class:InvalidEnum')
                if isequal(isTypeFcnHandle,@isenum)
                    isType=true;
                else
                    isType=false;
                end
            else
                error('Invalid port number');
            end
        end
    else
        error('Incorrect port designation');
    end
end

