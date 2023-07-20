

function symInfo=extractGlobalSymbolInfo(cpResFile)


    persistent stmts;
    if isempty(stmts)

        stmts.UndefinedFunctions=[...
        'SELECT Name FROM FunctionView ',...
        'WHERE File LIKE ''pst_stubs%'' ',...
'AND BodyKind=''Userdef'''...
        ];


        stmts.UndefinedVariables=[...
        'SELECT Name,Type FROM GlobalVariableView ',...
        'WHERE Package=''?extern'' ',...
'ORDER BY Name,Type'...
        ];


        stmts.EntryPoints=[...
        'SELECT CalleeFunction FROM FunctionCallView,FunctionCall,Function AS Callee ',...
        'WHERE CallerFunction LIKE ''main'' ',...
        'AND CalleeFunction NOT LIKE ''_init_globals'' ',...
        'AND FunctionCall.RefFunctionCall=FunctionCallView.RefFunctionCall ',...
        'AND FunctionCall.CalleeRefFunction=Callee.RefFunction ',...
        'AND Callee.BodyKind=1 ',...
'ORDER BY CalleeFunction'...
        ];


        stmts.GlobalVariables=[...
        'SELECT Name,Type,VariableStatus FROM GlobalVariableDetail ',...
        'WHERE Type NOT LIKE IsConstant <> '''' ',...
'ORDER BY Name'...
        ];


        stmts.GlobalDictionary=[...
        'SELECT DISTINCT Function,Name,AccessMode FROM GlobalVariableAccessView ',...
        'WHERE Function NOT LIKE ''_main_gen_init%'' ',...
        'AND Function NOT LIKE ''_init_globals%'' ',...
        'AND Function NOT LIKE ''main'' ',...
        'AND IsDead NOT LIKE 1 ',...
'ORDER BY Function,AccessMode,Name'...
        ];


        stmts.CallTree=[...
        'SELECT DISTINCT CallerFunction,CalleeFunction FROM FunctionCallView ',...
        'WHERE CalleeFunction NOT LIKE ''_main_gen_init_%'' ',...
        'AND CalleeFunction NOT LIKE ''_init_globals%'' ',...
        'AND CallerFunction <> ''main'' ',...
        'AND CallerFunction NOT LIKE ''_main_gen_%'' ',...
'ORDER BY CallerFunction,CalleeFunction'...
        ];
    end

    symInfo=[];


    dbObj=polyspace.internal.database.SqlDb(char(cpResFile),true,'obfuscated[e3yu7ypw5pMsWuFvKnuonJ5aHHwGHAqzCW]');
    modArgStmtObj=[];
    if dbObj.columnExists('','Function','ModifiedArgs')
        modArgStmtObj=polyspace.internal.database.SqlDbStatement(dbObj,'SELECT ModifiedArgs FROM Function WHERE Name=?');
    end


    funMap=containers.Map('KeyType','char','ValueType','any');
    varMap=containers.Map('KeyType','char','ValueType','any');



    callTree=dbObj.exec(stmts.CallTree);
    for ii=1:size(callTree,1)
        callerFun=getOrCreateFunInfo(callTree{ii,1});
        calleeFun=getOrCreateFunInfo(callTree{ii,2});
        callerFun.Callee=[callerFun.Callee,calleeFun];
    end


    undefinedFunctions=dbObj.exec(stmts.UndefinedFunctions);
    for ii=1:numel(undefinedFunctions)
        funInfo=getOrCreateFunInfo(undefinedFunctions{ii});
        funInfo.IsDefined=false;
    end


    entryPoints=dbObj.exec(stmts.EntryPoints);
    if numel(entryPoints)>0
        symInfo.EntryPoints(1,numel(entryPoints))=polyspace.internal.codeinsight.analyzer.FunInfo();
        for ii=1:numel(entryPoints)
            symInfo.EntryPoints(ii)=getOrCreateFunInfo(entryPoints{ii,1});
        end
    else
        symInfo.EntryPoints=polyspace.internal.codeinsight.analyzer.FunInfo.empty;
    end


    globalVariables=dbObj.exec(stmts.GlobalVariables);
    for ii=1:1:size(globalVariables,1)
        varInfo=getOrCreateVarInfo(globalVariables{ii,1});
        varInfo.Type=globalVariables{ii,2};
        varInfo.Status=globalVariables{ii,3};
    end


    undefinedVariables=dbObj.exec(stmts.UndefinedVariables);
    for ii=1:size(undefinedVariables,1)
        varInfo=getOrCreateVarInfo(undefinedVariables{ii,1});
        varInfo.Type=undefinedVariables{ii,2};
        varInfo.IsDefined=false;
    end


    globalDictionary=dbObj.exec(stmts.GlobalDictionary);
    for ii=1:size(globalDictionary,1)
        funInfo=getOrCreateFunInfo(globalDictionary{ii,1});
        varInfo=getOrCreateVarInfo(globalDictionary{ii,2});
        if globalDictionary{ii,3}=="Read"
            funInfo.GlobalRead=[funInfo.GlobalRead,varInfo];
        elseif globalDictionary{ii,3}=="Write"
            funInfo.GlobalWrite=[funInfo.GlobalWrite,varInfo];
        end
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
            if~isempty(modArgStmtObj)
                argList=modArgStmtObj.exec(funName);
                if iscellstr(argList)%#ok<ISCLSTR>
                    funInfo.ModifiedArgs=string(strsplit(argList{1},','));
                end
            end
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
