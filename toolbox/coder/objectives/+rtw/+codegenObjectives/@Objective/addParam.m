function addParam(obj,param,value)










    if nargin==1
        throw(MSLException([],message(...
        'Simulink:tools:noNameSpecifiedCSParameterError')));
    elseif nargin==2
        throw(MSLException([],message(...
        'Simulink:tools:noValueSpecifiedCSParameterError',param)));
    end
    [param,value]=convertStringsToChars(param,value);


    if~isempty(obj.paramHash.get(param))
        throw(MSLException([],message(...
        'Simulink:tools:existedCSParameterError',...
        param,obj.objectiveName)));
    end


    if isnumeric(value)||isa(value,'logical')
        switch value
        case 0
            value='off';
        case 1
            value='on';
        end
    end

    thisParam=rtw.codegenObjectives.Parameter(param,value,obj.objectiveName);


    obj.parameters{end+1}=thisParam;
    obj.paramHash.put(thisParam.name,thisParam.value);
    obj.paramHashPos.put(thisParam.name,length(obj.parameters));

