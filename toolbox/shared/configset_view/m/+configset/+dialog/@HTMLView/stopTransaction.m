function stopTransaction(obj,from)

    if obj.transaction>0
        obj.transaction=obj.transaction-1;
    end


    if obj.debugMode
        if isempty(from)
            from='';
        end
        fprintf('stop:\t%d from %s\n',obj.transaction,from);
    end