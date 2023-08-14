function destInfoStruct=resolveDest(arg)

















    if isa(arg,'struct')

        if isfield(arg,'domain')&&isfield(arg,'artifact')&&isfield(arg,'id')
            arg=slreq.structToObj(arg);
        else
            error(message('Slvnv:slreq:ErrorInvalidType','resolveDest()','struct'));
        end
    end

    destInfoStruct=slreq.utils.apiObjToIdsStruct(arg);

end

