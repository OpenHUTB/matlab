function b=isPersistentInitCondition(varMap,cond)




    b=false;


    while strcmp(cond.kind,'PARENS')
        cond=cond.Arg;
    end

    if strcmp(cond.kind,'CALL')
        fcnName=string(cond.Left);
        arg=cond.Right;

        if strcmp(fcnName,'isempty')&&strcmp(arg.kind,'ID')

            var=string(arg);
            b=varMap.isKey(var);
        end
    elseif strcmp(cond.kind,'OROR')
        b=internal.mtree.isPersistentInitCondition(varMap,cond.Left)||...
        internal.mtree.isPersistentInitCondition(varMap,cond.Right);
    end
end


