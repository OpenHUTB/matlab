function out=createDefaultCustomAttributesObject(sourceDD,packageName,scName)





















    out=[];
    try
        if~strcmp(pkgName,'SimulinkBuiltin')
            out=processcsc('CreateAttributesObject',packageName,scName);
        end
    catch me
        rethrow(me);
    end
end
