function checkObjectClass(obj,propVal)




    if iscell(propVal)
        classchk=cellfun(@(x)isa(x,'em.EmStructures'),propVal);
        if~all(classchk,"all")
            cx=propVal{~classchk};
            metaclassdata=metaclass(cx);
            error(message('antenna:antennaerrors:InvalidValue','Element','an antenna',metaclassdata.Name));
        end
    else
        metaclassdata=metaclass(propVal(1));
        if~all(arrayfun(@(x)isa(x,'em.EmStructures'),propVal),"all")
            error(message('antenna:antennaerrors:InvalidValue','Element','an antenna',metaclassdata.Name));
        end
    end
