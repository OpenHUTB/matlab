function errors=validate(target)































    target.registered_blocks={};

    nodes=target.activeList.find('-class','RTWConfiguration.Node');



    keys=get(nodes,'sourceLibrary');
    if iscell(keys)
        [y,idx]=sort(keys);
        nodes=nodes(idx);
    end




    errors={};
    for i=1:length(nodes)
        err=validate(nodes(i),target);
        if~isempty(err)
            if iscell(err)
                errors={errors{:},err{:}};
            else
                errors={errors{:},err};
            end
        end
    end

    target.errors=errors;










