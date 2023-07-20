function logException(excep)





    persistent dbgLvl;
    if isempty(dbgLvl)
        dbgLvl=Simulink.variant.reducer.utils.getDebugLevel();
    end
    if dbgLvl>0
        disp('Caught exception');
        disp(excep);
        stack=dbstack;
        maxStackCount=5;
        len=min(maxStackCount,length(stack));

        disp('DBStack information');
        logStack(stack,len);
        len=min(maxStackCount,length(excep.stack));

        disp('Exception Stack information');
        logStack(excep.stack,len);
    end
end

function logStack(stack,len)
    for idx=1:len
        currStack=stack(idx);
        fprintf('ReducerDebugInfo: file:%s, name:%s, line:%d\n',...
        currStack.file,currStack.name,int32(currStack.line));
    end
end
