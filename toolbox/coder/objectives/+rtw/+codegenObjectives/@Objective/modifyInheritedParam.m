function modifyInheritedParam(obj,param,value)







    base=obj.baseObjective;

    if nargin==1
        throw(MSLException([],message(...
        'Simulink:tools:noNameSpecifiedCSParameterError')));
    elseif nargin==2
        throw(MSLException([],message(...
        'Simulink:tools:noValueSpecifiedCSParameterError',param)));
    end
    [param,value]=convertStringsToChars(param,value);

    if isempty(base)
        throw(MSLException([],message(...
        'Simulink:tools:noBaseError',obj.objectiveName)));
    end

    if~rtw.codegenObjectives.Parameter.isValidParam(param)
        throw(MSLException([],message(...
        'Simulink:tools:invalidCSParameterError',param)));
    end

    valHash=obj.paramHash.get(param);
    if isempty(valHash)
        throw(MSLException([],message(...
        'Simulink:tools:CSParameterNotExistedInBase',param,base)));
    end


    if isnumeric(value)||isa(value,'logical')
        switch value
        case 0
            value='Off';
        case 1
            value='On';
        end
    end

    if ischar(value)
        if~strcmpi(value,valHash)
            obj.parameters{obj.paramHashPos.get(param)}=rtw.codegenObjectives.Parameter(param,value,obj.objectiveName);
        end
    end

    if isnumeric(value)
        if value~=valHash
            obj.parameters{obj.paramHashPos.get(param)}=rtw.codegenObjectives.Parameter(param,value,obj.objectiveName);
        end
    end
