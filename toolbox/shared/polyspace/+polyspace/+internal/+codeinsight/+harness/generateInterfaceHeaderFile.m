

function generateInterfaceHeaderFile(codeInfo,functionList,filename,varargin)



    isCharCompatible=@(x)ischar(x)||(isstring(x)&&isscalar(x));
    isCellStrCompatible=@(x)iscellstr(x)||isstring(x);
    isCellOrCharCompatible=@(x)isCellStrCompatible(x)||isCharCompatible(x);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addRequired(argParser,'codeInfo',@(x)isa(x,'polyspace.internal.codeinsight.parser.CodeInfo'));
        addRequired(argParser,'functionList',@(x)isCellOrCharCompatible(x));
        addRequired(argParser,'filename',@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'Debug',false,@(x)isa(x,'logical'));
        addParameter(argParser,'GenerateDeclarationForAllSymbols',false,@(x)isa(x,'logical'));
    end
    argParser.parse(codeInfo,functionList,filename,varargin{:});

    funMap=containers.Map;

    function globalAccesses=getVariableAccesses(fun)
        if funMap.isKey(fun.Name)


            globalAccesses=funMap(fun.Name);
        else

            globalAccesses=union(fun.ReadVars,fun.WrittenVars);
            if~isequal(fun.CalledFuns,polyspace.internal.codeinsight.parser.FunInfo.empty)

                for cidx=1:numel(fun.CalledFuns)
                    globalAccesses=union(globalAccesses,getVariableAccesses(fun.CalledFuns(cidx)));
                end
            end


            funMap(fun.Name)=globalAccesses;
        end
    end

    variablesToExtract=polyspace.internal.codeinsight.parser.VarInfo.empty;
    if~isempty(functionList)
        globalFunctionInfoList=codeInfo.Functions(ismember([codeInfo.Functions.Name],functionList));
        for gF=globalFunctionInfoList
            variablesToExtract=union(variablesToExtract,getVariableAccesses(gF));
        end
    end

    vTypes=[variablesToExtract.Type];
    if~isempty(vTypes)
        variablesToExtract=variablesToExtract([vTypes.IsImportCompliant]);
    end


    functionsNameToExtract=string(funMap.keys);
    functionsToExtract=polyspace.internal.codeinsight.parser.FunInfo.empty;
    if~isempty(functionsNameToExtract)
        functionsToExtract=codeInfo.Functions(ismember([codeInfo.Functions.Name],functionsNameToExtract));
    end
    typeToExtract=polyspace.internal.codeinsight.parser.TypeInfo.empty;

    if~isempty(functionsToExtract)
        functionsToExtract=functionsToExtract([functionsToExtract.IsImportCompliant]);
        typeToExtract=union([functionsToExtract.ReturnedType],[functionsToExtract.FormalArguments]);
    end
    if~isempty(variablesToExtract)
        typeToExtract=union(typeToExtract,[variablesToExtract.Type]);
    end





    if argParser.Results.Debug
        fName="";
        if~isempty(functionsToExtract)
            fName=[functionsToExtract.Name];
        end
        vName="";
        if~isempty(variablesToExtract)
            vName=[variablesToExtract.Name];
        end
        tName="";
        if~isempty(typeToExtract)
            tName=[typeToExtract.Name];
        end
        fprintf("Extracting functions: %s\n",fName);
        fprintf("Extracting variables: %s\n",vName);
        fprintf("Extracting types: %s\n",tName);
    end


    harnessCode.TypeDefs=getTypeDefs(typeToExtract);
    harnessCode.TypeDecls=getTypeDecls(typeToExtract);
    typestr="/* Type definitions */"+newline+...
    sprintf("%s\n",harnessCode.TypeDecls)+...
    newline+...
    sprintf("%s\n",harnessCode.TypeDefs)+...
    newline;

    varDeclList="extern "+[variablesToExtract.TypeName]+";";
    varstr="/* Variables declarations */"+newline+...
    sprintf("%s\n",varDeclList)+...
    newline;

    if~argParser.Results.GenerateDeclarationForAllSymbols

        functionsToExtract=functionsToExtract([functionsToExtract.IsImportCompliant]);
    end

    funcDeclList=[functionsToExtract.Signature]+";";
    funcstr="/* Functions declarations */"+newline+...
    sprintf("%s\n",funcDeclList)+...
    newline;

    headerstr="/* Auto generated interface header file */"+newline;
    str=headerstr+newline+typestr+newline+varstr+newline+funcstr+newline;
    fid=fopen(filename,'w');
    fprintf(fid,"%s",str);
    fclose(fid);

end

function typeDefs=getTypeDefs(typelist)
    typeDefs=string([]);

    function extractTypeDefs(t)
        def=t.StubDefinition;
        if~isempty(t.Members)
            for m=t.Members
                extractTypeDefs(m.Type);
            end
        end
        if~isempty(t.Type)
            extractTypeDefs(t.Type);
        end
        if~ismember(def,typeDefs)
            typeDefs(end+1)=def;
        end
    end
    if~isempty(typelist)
        for t=typelist
            extractTypeDefs(t);
        end
    end
end

function typeDecls=getTypeDecls(typelist)
    typeDecls=string([]);

    function extractTypeDecls(t)
        def=t.StubDeclaration;
        if~isempty(t.Members)
            for m=t.Members
                extractTypeDecls(m.Type);
            end
        end
        if~isempty(t.Type)
            extractTypeDecls(t.Type);
        end
        if~ismember(def,typeDecls)
            typeDecls(end+1)=def;
        end
    end
    if~isempty(typelist)
        for t=typelist
            extractTypeDecls(t);
        end
    end
end