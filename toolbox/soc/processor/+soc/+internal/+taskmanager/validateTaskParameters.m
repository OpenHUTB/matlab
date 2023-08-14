function validateTaskParameters(name,type,period,core,priority,...
    validCores,validPriorities)




    import soc.internal.taskmanager.*

    locValidateTaskName(name);
    locValidateTaskType(name,type);
    if isequal(type,'Timer-driven')
        locValidateTaskPeriod(name,period);
    end
    locValidateTaskCore(name,core,validCores);
    if isequal(type,'Event-driven')
        locValidateTaskPriority(name,priority,validPriorities);
    end
end


function locValidateTaskName(name)
    if~iscvar(name)||(strlength(name)>55)||(name(1)=='_')
        error(message('soc:scheduler:InvalidTaskNameShort',name));
    end
end

function locValidateTaskType(name,type)
    validTypes={'Timer-driven','Event-driven'};
    if~ismember(type,validTypes)
        error(message('soc:scheduler:InvalidTaskType',...
        name,validTypes{1},validTypes{2}));
    end
end

function locValidateTaskPeriod(name,valStr)
    if isnumeric(valStr),valStr=num2str(valStr);end
    if~iscvar(valStr)
        val=eval(valStr);
        errMsg=message('soc:scheduler:InvalidPeriod',valStr,name);
        soc.internal.BlockParameterValidator.isInRange(val,[0,inf],errMsg);
    end
end

function locValidateTaskCore(name,valStr,validVals)
    if isnumeric(valStr),valStr=num2str(valStr);end
    if~iscvar(valStr)
        val=eval(valStr);
        if isscalar(validVals)
            errMsg=message('soc:scheduler:InvalidCoreNumOneCore',valStr,name,...
            validVals);
        else
            errMsg=message('soc:scheduler:InvalidCoreNum',valStr,name,...
            validVals(1),validVals(end));
        end
        soc.internal.BlockParameterValidator.isMemberOf(val,validVals,errMsg);
    end
end

function locValidateTaskPriority(name,valStr,validVals)
    if isnumeric(valStr),valStr=num2str(valStr);end
    if~iscvar(valStr)
        val=eval(valStr);
        errMsg=message('soc:scheduler:InvalidPriority',valStr,name,...
        validVals(1),validVals(end));
        soc.internal.BlockParameterValidator.isMemberOf(val,validVals,errMsg);
    end
end