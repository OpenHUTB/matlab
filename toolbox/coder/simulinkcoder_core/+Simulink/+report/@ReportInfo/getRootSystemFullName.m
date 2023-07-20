function out=getRootSystemFullName(obj)
    if~isempty(obj.SourceSubsystemFullName)
        out=obj.SourceSubsystemFullName;
    else
        out=obj.ModelName;
    end
end
