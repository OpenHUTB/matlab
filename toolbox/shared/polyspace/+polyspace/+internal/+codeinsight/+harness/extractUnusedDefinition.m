

function res=extractUnusedDefinition(cpResDir,headerfilepath)

    ps_internal_fe=fullfile(cpResDir,'ps_internal_fe.db');
    dbObj=polyspace.internal.database.SqlDb(ps_internal_fe,true);
    res.unusedMacros=getUnusedMacros(dbObj,headerfilepath);
    res.unusedTypes=getUnusedTypes(dbObj,headerfilepath);
    res.undefinedFunctions=getUndefinedFunctions(dbObj,headerfilepath);
    res.linesToRemove=[res.unusedMacros.Lines,res.unusedTypes.Lines,res.undefinedFunctions.Lines];
    dbObj.close();
    clear dbObj;
end

function res=getUnusedMacros(dbObj,headerfilepath)

    stmts="SELECT File,DeclLineNum FROM MacroView "+...
    "WHERE RefCount<1 "+...
    "AND File = """+headerfilepath+"""";

    tmp=dbObj.exec(char(stmts));
    m=containers.Map();
    [nElement,~]=size(tmp);
    for idx=1:nElement
        f=tmp{idx,1};
        l=tmp{idx,2};
        if m.isKey(f)
            m(f)=[m(f),l];
        else
            m(f)=[l];
        end
    end
    keys=m.keys;
    res=struct('File',{},'Lines',{});
    for idx=1:numel(keys)
        res(idx).File=keys(idx);
        res(idx).Lines=sort(m(char(keys(idx))));
    end
end

function res=getUnusedTypes(dbObj,headerfilepath)

    stmts="SELECT File,DeclLineNum FROM TypeView "+...
    "WHERE DeclLineNum = "+...
    "    (SELECT DeclLineNum From Type"+...
    "    WHERE RefCount=0 ) "+...
    "AND File = """+headerfilepath+"""";

    tmp=dbObj.exec(char(stmts));
    m=containers.Map();
    [nElement,~]=size(tmp);
    for idx=1:nElement
        f=tmp{idx,1};
        l=tmp{idx,2};
        if m.isKey(f)
            m(f)=[m(f),l];
        else
            m(f)=[l];
        end
    end
    keys=m.keys;
    res=struct('File',{},'Lines',{});
    for idx=1:numel(keys)
        res(idx).File=keys(idx);
        res(idx).Lines=sort(m(char(keys(idx))));
    end
end

function res=getUndefinedFunctions(dbObj,headerfilepath)
    stmts="SELECT F.File, F.Name, F.DeclLineNum FROM [FunctionView] AS F "+...
    "WHERE F.Name NOT IN"+...
    "(SELECT F2.Name FROM [FunctionView] AS F2 "+...
    "WHERE F2.isDefined=1)"+...
    "AND File = """+headerfilepath+"""";

    tmp=dbObj.exec(char(stmts));
    m=containers.Map();
    [nElement,~]=size(tmp);
    for idx=1:nElement
        f=tmp{idx,1};
        n=tmp{idx,2};
        l=tmp{idx,3};
        if m.isKey(f)
            current=m(f);
            current.Lines=[current.Lines,l];
            current.Functions=[current.Functions,n];
            m(f)=current;
        else
            current.Lines=l;
            current.Functions=string(n);
            m(f)=current;
        end
    end
    keys=m.keys;
    res=struct('File',{},'Functions',{},'Lines',{});
    for idx=1:numel(keys)
        res(idx).File=keys(idx);
        res(idx).Functions=m(char(keys(idx))).Functions;
        res(idx).Lines=m(char(keys(idx))).Lines;
    end
end