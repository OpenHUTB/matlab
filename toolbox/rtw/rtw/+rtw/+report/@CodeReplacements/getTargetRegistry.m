function tr=getTargetRegistry(obj)




    if isempty(obj.TargetRegistry)
        obj.TargetRegistry=RTW.TargetRegistry.get;
    end
    tr=obj.TargetRegistry;
end
