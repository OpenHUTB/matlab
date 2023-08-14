function out=getRootSystem(obj)
    if~isempty(obj.SourceSubsystem)
        out=obj.SourceSubsystem;
    else
        out=obj.ModelName;
    end
end
