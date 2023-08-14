

function res=getGlobalIOData(data)



    res=struct("UndefinedFunctions",[],...
    "UndefinedVariables",[],...
    "EntryPoints",struct("Name",{}),...
    "GlobalVariables",struct("Name",{},"Type",{},"VariableStatus",{}),...
    "GlobalDictionary",struct("Function",{},"Name",{},"AccessMode",{}),...
    "CallTree",struct("CallerFunction",{},"CalleeFunction",{}),...
    "Errors",[]);


    res.GlobalVariables=arrayfun(@(x)struct("Name",x.Name,"Type",x.Type,"VariableStatus",x.Status),data.Variables.Type.Name);


    funMap=containers.Map;
    callTreeMap=containers.Map;

    for idx=1:numel(data.Functions)
        caller=data.Functions(idx);
        if~callTreeMap.isKey(caller.Name)
            callTreeMap(caller.Name)=string([]);
        end
        if~isequal(caller.CalledFuns,polyspace.internal.codeinsight.parser.FunInfo.empty)
            for fidx=1:numel(caller.CalledFuns)
                callee=caller.CalledFuns(fidx);
                res.CallTree(end+1)=struct("CallerFunction",caller.Name,"CalleeFunction",callee.Name);
                if~callTreeMap.isKey(callee.Name)
                    callTreeMap(callee.Name)=caller.Name;
                else
                    callTreeMap(callee.Name)=union(callTreeMap(callee.Name),caller.Name);
                end
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

    entryPoints=string([]);
    for callee=callTreeMap.Keys
        callerList=callTreeMap(callee);
        if isempty(callerList)
            entryPoints(end+1)=callee;%#ok<AGROW>
        end
    end
    res.EntryPoints=arrayfun(@(x)struct("Name",x.Name),entryPoints);


    function[globalRead,globalWrite]=getGlobalIO(fun)
        if funMap.isKey(fun.Name)


            vars=funMap(fun.Name);
            globalRead=vars.globalRead;
            globalWrite=vars.globalWrite;
        else

            globalRead=string(arrayfun(@(x)(x.Name),fun.ReadVars));
            globalWrite=string(arrayfun(@(x)(x.Name),fun.WrittenVars));
            if~isequal(fun.CalledFuns,polyspace.internal.codeinsight.parser.FunInfo.empty)

                for cidx=1:numel(fun.CalledFuns)
                    [r,w]=getGlobalIO(fun.CalledFuns(cidx));
                    globalRead=union(globalRead,r);
                    globalWrite=union(globalWrite,w);
                end
            end


            funMap(fun.Name)=struct('globalRead',globalRead,'globalWrite',globalWrite);
        end
    end
end
