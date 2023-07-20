

function symInfo=extractGlobalSymbolInfo(parseInfo)
    symInfo=[];


    funMap=containers.Map('KeyType','char','ValueType','any');
    varMap=containers.Map('KeyType','char','ValueType','any');

    isCalled=string([]);
    for ii=1:numel(parseInfo.Functions)
        caller=parseInfo.Functions(ii);
        callerFun=getOrCreateFunInfo(caller.Name);
        callee=caller.CalledFuns;
        for jj=1:numel(callee)
            calleeFun=getOrCreateFunInfo(callee(jj).Name);
            callerFun.Callee=[callerFun.Callee,calleeFun];
            isCalled=union(isCalled,callee(jj).Name);
        end
        callerFun.IsDefined=caller.IsDefined;
        for jj=1:numel(caller.ReadVars)
            varInfo=getOrCreateVarInfo(caller.ReadVars(jj).Name);
            callerFun.GlobalRead=[callerFun.GlobalRead,varInfo];
        end
        for jj=1:numel(caller.WrittenVars)
            varInfo=getOrCreateVarInfo(caller.WrittenVars(jj).Name);
            callerFun.GlobalWrite=[callerFun.GlobalWrite,varInfo];
        end
    end
    entryPoints=string([]);
    if numel(isCalled)>0
        entryPoints=setdiff([parseInfo.Functions.Name],isCalled);
    end
    if numel(entryPoints)>0
        symInfo.EntryPoints(1,numel(entryPoints))=polyspace.internal.codeinsight.analyzer.FunInfo();
        for ii=1:numel(entryPoints)
            symInfo.EntryPoints(ii)=getOrCreateFunInfo(entryPoints(ii));
        end
    else
        symInfo.EntryPoints=polyspace.internal.codeinsight.analyzer.FunInfo.empty;
    end

    for ii=1:numel(parseInfo.Variables)
        varInfo=getOrCreateVarInfo(parseInfo.Variables(ii).Name);
        varInfo.Type=parseInfo.Variables(ii).Type.UnderlayingType;
        varInfo.IsDefined=parseInfo.Variables(ii).IsDefined;

    end


    funs=funMap.values();
    symInfo.FunInfo=[funs{:}];
    vars=varMap.values();
    symInfo.VarInfo=[vars{:}];

    function funInfo=getOrCreateFunInfo(funName)
        if funMap.isKey(funName)
            funInfo=funMap(funName);
        else
            funInfo=polyspace.internal.codeinsight.analyzer.FunInfo();
            funInfo.Name=funName;
            funMap(funName)=funInfo;
        end
    end

    function varInfo=getOrCreateVarInfo(varName)
        if varMap.isKey(varName)
            varInfo=varMap(varName);
        else
            varInfo=polyspace.internal.codeinsight.analyzer.VarInfo();
            varInfo.Name=varName;
            varMap(varName)=varInfo;
        end
    end
end

