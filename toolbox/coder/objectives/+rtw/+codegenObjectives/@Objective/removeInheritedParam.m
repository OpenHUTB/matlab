function removeInheritedParam(obj,param)







    base=obj.baseObjective;

    if nargin<2
        throw(MSLException([],message(...
        'Simulink:tools:noNameSpecifiedCSParameterError')));
    end
    param=convertStringsToChars(param);

    if isempty(base)
        throw(MSLException([],message(...
        'Simulink:tools:noBaseError',obj.objectiveName)));
    end

    if isempty(obj.paramHash.get(param))
        throw(MSLException([],message(...
        'Simulink:tools:CSParameterNotExistedInBase',param,base)));
    else
        pos=obj.paramHashPos.get(param);
        cellArray=obj.parameters;
        cellArray=[cellArray(1:pos-1),cellArray(pos+1:length(cellArray))];

        for i=pos:length(cellArray)
            obj.paramHashPos.put(cellArray{i}.name,obj.paramHashPos.get(cellArray{i}.name)-1);
        end

        obj.parameters=cellArray;
    end

