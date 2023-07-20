function removeInheritedCheck(obj,check)







    if nargin<2
        throw(MSLException([],message(...
        'Simulink:tools:noNameSpecifiedCheckError')));
    end
    check=convertStringsToChars(check);

    base=obj.baseObjective;
    if isempty(base)
        throw(MSLException([],message(...
        'Simulink:tools:noBaseError',obj.objectiveName)));
    end

    if isempty(obj.checkHash.get(check))
        throw(MSLException([],message(...
        'Simulink:tools:checkNotExistedInBase',check,base)));
    else
        pos=obj.checkHashPos.get(check);
        cellArray=obj.checks;
        cellArray=[cellArray(1:pos-1),cellArray(pos+1:length(cellArray))];

        for i=pos:length(cellArray)
            obj.checkHashPos.put(cellArray{i}.MAC,obj.checkHashPos.get(cellArray{i}.MAC)-1);
        end

        obj.checks=cellArray;
    end
