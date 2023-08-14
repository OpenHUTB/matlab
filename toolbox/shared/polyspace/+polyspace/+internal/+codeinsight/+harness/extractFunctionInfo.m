

function[codeInfo,functionList]=extractFunctionInfo(sourceFiles,resDir,codeInfo,varargin)




    isCharCompatible=@(x)ischar(x)||(isstring(x)&&isscalar(x));
    isCellStrCompatible=@(x)iscellstr(x)||isstring(x);
    isCellOrCharCompatible=@(x)isCellStrCompatible(x)||isCharCompatible(x);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addRequired(argParser,'sourceFiles',@(x)isCellOrCharCompatible(x));
        addRequired(argParser,'resDir',@(x)isCellOrCharCompatible(x));
        addRequired(argParser,'codeInfo',@(x)isa(x,'polyspace.internal.codeinsight.parser.CodeInfo'));
        addParameter(argParser,'Debug',false,@(x)isa(x,'logical'));
        addParameter(argParser,'GenerateDeclarationForAllSymbols',false,@(x)isa(x,'logical'));
        addParameter(argParser,'MacroInvocation',false,@(x)isa(x,'logical'));
    end
    argParser.parse(sourceFiles,resDir,codeInfo,varargin{:});


    sourceFiles=strip(string(sourceFiles));
    functionList=[];

    for fIdx=1:numel(sourceFiles)
        [~,f,ext]=fileparts(sourceFiles(fIdx));
        filename=f+ext;
        fList=getFunctionsInFile(filename,fullfile(resDir,'ps_results.pscp'));
        funObjs=[];
        if numel(fList)>0
            t=cell2table(fList,'VariableNames',{'Name','StartLine','StartCol','EndLine','EndCol'});
            funObjs=arrayfun(@(x)createFunInfo(x,filename),table2struct(t));
            functionList=[functionList,string({funObjs.Name})];%#ok<AGROW>
        end

        resDirs=dir([char(resDir),'/C-ALL/*/*.db']);
        resDbForMacro="";
        if argParser.Results.MacroInvocation

            for idx=1:numel(resDirs)
                current=string(fullfile(resDirs(idx).folder,resDirs(idx).name));
                if isDbResForFile(filename,current)
                    resDbForMacro=current;
                    break;
                end
            end

            if isempty(resDbForMacro)
                error("Did not find analysis results for file '%s'",filename);
            end
        end
        resDbForType=fullfile(resDir,'ps_internal_fe.db');

        if argParser.Results.Debug
            if argParser.Results.MacroInvocation
                fprintf("Intermediate result database (MACROS) for file '%s' is:  %s \n",filename,resDbForMacro);
            end
            fprintf("Intermediate result database (LOCAL TYPES) for file '%s' is:  %s \n",filename,resDbForType);
        end


        for fidx=1:numel(funObjs)
            fun=funObjs(fidx);
            [fhandle,exists]=codeInfo.addFunction(fun.Name);
            if~exists



                continue;
            end
            if argParser.Results.MacroInvocation
                fhandle.MacroInvocation=string(getMacroInvocatedInFunction(fun,resDbForMacro))';
            end
            fhandle.LocalTypes=string(getLocalTypeInFunction(fun,resDbForType))';
        end

    end


    symInfo=polyspace.internal.codeinsight.analyzer.extractGlobalSymbolInfo(fullfile(resDir,'ps_results.pscp'));
    for fidx=1:numel(symInfo.FunInfo)
        fun=symInfo.FunInfo(fidx);
        [fhandle,exists]=codeInfo.addFunction(fun.Name);
        if~exists



            continue;
        end
        fhandle.IsDefined=fun.IsDefined;
        varNames=[codeInfo.Variables.Name];
        if~isempty(varNames)
            fhandle.ReadVars=codeInfo.Variables(ismember([codeInfo.Variables.Name],string([fun.GlobalRead.Name])));
            for rIdx=1:numel(fhandle.ReadVars)
                fhandle.ReadVars(rIdx).IsRead=true;
            end
            fhandle.WrittenVars=codeInfo.Variables(ismember([codeInfo.Variables.Name],string([fun.GlobalWrite.Name])));
            for wIdx=1:numel(fhandle.WrittenVars)
                fhandle.WrittenVars(wIdx).IsWritten=true;
            end
        end
        functionNames=[codeInfo.Functions.Name];
        if~isempty(functionNames)
            fhandle.CalledFuns=codeInfo.Functions(ismember([codeInfo.Functions.Name],string([fun.Callee.Name])));
        end
    end
end


function funcInfo=createFunInfo(c,path)
    funcInfo.DefinitionFile.Path=path;
    funcInfo.Name=c.Name;
    funcInfo.DefinitionBlock.StartLine=c.StartLine;
    funcInfo.DefinitionBlock.StartCol=c.StartCol;
    funcInfo.DefinitionBlock.EndLine=c.EndLine;
    funcInfo.DefinitionBlock.EndCol=c.EndCol;
end


function functionList=getFunctionsInFile(filename,cpResFile)

    dbObj=polyspace.internal.database.SqlDb(char(cpResFile),true,'obfuscated[e3yu7ypw5pMsWuFvKnuonJ5aHHwGHAqzCW]');
    stmts.FunctionInFile="SELECT FunctionView.Name, FunctionView.LineNum, FunctionView.ColNum, NavigBlockView.EndLineNum,  NavigBlockView.EndColNum"+newline+...
    "FROM FunctionView,NavigBlockView"+newline+...
    "WHERE FunctionView.File LIKE '%"+filename+"' "+newline+...
    "AND FunctionView.File=NavigBlockView.Path "+newline+...
    "AND FunctionView.LineNum=NavigBlockView.LeadingLineNum"+newline+...
    "AND FunctionView.ColNum=NavigBlockView.LeadingColNum"+newline+...
    "ORDER BY FunctionView.LineNum;";
    functionList=dbObj.exec(char(stmts.FunctionInFile));
end


function macroList=getMacroInvocatedInFunction(funcInfo,cpFeResFile)
    dbObj=polyspace.internal.database.SqlDb(char(cpFeResFile),true);
    stmts.MacroList="SELECT DISTINCT Macro from MacroInvocationView"+newline+...
    "WHERE  File LIKE '%"+funcInfo.DefinitionFile.Path+"'"+newline+...
    "AND (LineNum > "+funcInfo.DefinitionBlock.StartLine+" OR (LineNum = "+funcInfo.DefinitionBlock.StartLine+" AND ColNum > "+funcInfo.DefinitionBlock.StartCol+") )"+newline+...
    "AND (LineNum < "+funcInfo.DefinitionBlock.EndLine+" OR LineNum = "+funcInfo.DefinitionBlock.EndLine+" AND ColNum < "+funcInfo.DefinitionBlock.EndCol+");";
    macroList=dbObj.exec(char(stmts.MacroList));
    if~isempty(macroList)
        macroList(cellfun('isempty',macroList))=[];
    end
end


function macroList=getMacroDefinedInFile(filename,cpFeResFile)
    dbObj=polyspace.internal.database.SqlDb(char(cpFeResFile),true);
    stmts="SELECT Macro,RefCount FROM MacroView "+...
    "WHERE File LIKE '%"+filename+"' ;";
    macroList=dbObj.exec(char(stmts));
end


function localTypeList=getLocalTypeInFunction(funcInfo,cpFeResFile)
    dbObj=polyspace.internal.database.SqlDb(char(cpFeResFile),true);
    stmts.TypeList="SELECT DISTINCT Type from VariableView"+newline+...
    "WHERE  File LIKE '%"+funcInfo.DefinitionFile.Path+"'"+newline+...
    "AND (DeclLineNum > "+funcInfo.DefinitionBlock.StartLine+" OR (DeclLineNum = "+funcInfo.DefinitionBlock.StartLine+" AND DeclColNum > "+funcInfo.DefinitionBlock.StartCol+") )"+newline+...
    "AND (DeclLineNum < "+funcInfo.DefinitionBlock.EndLine+" OR DeclLineNum = "+funcInfo.DefinitionBlock.EndLine+" AND DeclColNum < "+funcInfo.DefinitionBlock.EndCol+");";
    localTypeList=dbObj.exec(char(stmts.TypeList));
    if~isempty(localTypeList)&&iscell(localTypeList)
        localTypeList(cellfun('isempty',localTypeList))=[];
    end
end


function res=isDbResForFile(filename,cpResFile)
    dbObj=polyspace.internal.database.SqlDb(char(cpResFile),true);
    stmts.ExistFile="SELECT COUNT(Path)"+newline+...
    "FROM File"+newline+...
    "WHERE Path LIKE '%"+filename+"';";
    count=dbObj.exec(char(stmts.ExistFile));
    res=(count==1);
end
