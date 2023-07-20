function[firstPart,lastPart]=getSubsystemName(subsysName)

    a=strfind(subsysName,'/');
    if isempty(a)
        lastPart='';
        firstPart=subsysName;
    else
        lastPart=subsysName(a(1)+1:end);
        firstPart=subsysName(1:a(1)-1);
    end

    if isempty(firstPart)
        error('Model name cannot be empty');
    end

