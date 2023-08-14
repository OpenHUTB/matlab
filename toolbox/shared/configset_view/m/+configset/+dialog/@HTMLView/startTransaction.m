function startTransaction(obj,from)


    obj.transaction=obj.transaction+1;


    if obj.debugMode
        if isempty(from)
            from='';
        end
        fprintf('start:\t%d from %s\n',obj.transaction,from);
    end
