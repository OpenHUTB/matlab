function result=copyContainersMap(obj)



    result=containers.Map;
    names=obj.keys;

    if~isa(obj,'containers.Map')
        error(message('EDALink:boardmanager:NotContainersMap'));
    end

    for m=1:numel(names)
        prop=obj(names{m});
        if isa(prop,'matlab.mixin.Copyable')
            result(names{m})=copy(obj(names{m}));
        elseif isa(prop,'handle')
            error(message('EDALink:boardmanager:NoCopyFunction',names{m}));
        else

            result(names{m})=prop;
        end
    end


