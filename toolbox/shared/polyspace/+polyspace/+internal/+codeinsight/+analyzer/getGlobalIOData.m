

function res=getGlobalIOData(data)



    res=struct("UndefinedFunctions",[],...
    "UndefinedVariables",[],...
    "EntryPoints",struct("Name",{}),...
    "GlobalVariables",struct("Name",{},"Type",{},"VariableStatus",{}),...
    "GlobalDictionary",struct("Function",{},"Name",{},"AccessMode",{}),...
    "CallTree",struct("CallerFunction",{},"CalleeFunction",{}),...
    "Errors",[]);

    res.EntryPoints=arrayfun(@(x)struct("Name",x.Name),data.EntryPoints);
    res.GlobalVariables=arrayfun(@(x)struct("Name",x.Name,"Type",x.Type,"VariableStatus",x.Status),data.VarInfo);


    funMap=containers.Map;

    for idx=1:numel(data.FunInfo)
        caller=data.FunInfo(idx);
        if~isequal(caller.Callee,polyspace.internal.codeinsight.analyzer.FunInfo.empty)
            for fidx=1:numel(caller.Callee)
                callee=caller.Callee(fidx);
                res.CallTree(end+1)=struct("CallerFunction",caller.Name,"CalleeFunction",callee.Name);
            end
        end


        [globalRead,globalWrite]=getGlobalIO(caller);

        for rIdx=1:numel(globalRead)
            res.GlobalDictionary(end+1)=struct("Function",caller.Name,"Name",globalRead(rIdx),"AccessMode","Read");
        end
        for wIdx=1:numel(globalWrite)
            res.GlobalDictionary(end+1)=struct("Function",caller.Name,"Name",globalWrite(wIdx),"AccessMode","Write");
        end
    end


    function[globalRead,globalWrite]=getGlobalIO(fun)
        if funMap.isKey(fun.Name)


            vars=funMap(fun.Name);
            globalRead=vars.globalRead;
            globalWrite=vars.globalWrite;
        else

            globalRead=string(arrayfun(@(x)(x.Name),fun.GlobalRead));
            globalWrite=string(arrayfun(@(x)(x.Name),fun.GlobalWrite));
            if~isequal(fun.Callee,polyspace.internal.codeinsight.analyzer.FunInfo.empty)

                for cidx=1:numel(fun.Callee)
                    [r,w]=getGlobalIO(fun.Callee(cidx));
                    globalRead=union(globalRead,r);
                    globalWrite=union(globalWrite,w);
                end
            end


            funMap(fun.Name)=struct('globalRead',globalRead,'globalWrite',globalWrite);
        end
    end
end
