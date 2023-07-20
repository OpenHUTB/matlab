function resetTransaction(obj,from)


    obj.transaction=0;


    if obj.debugMode
        if isempty(from)
            from='';
        end
        fprintf('reset:\t%d from %s\n',obj.transaction,from);
    end
