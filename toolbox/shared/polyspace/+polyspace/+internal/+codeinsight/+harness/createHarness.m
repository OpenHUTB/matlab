

function createHarness(functionList,codeInfo,globalInfo,varargin)


    isCharCompatible=@(x)ischar(x)||(isstring(x)&&isscalar(x));
    isCellStrCompatible=@(x)iscellstr(x)||isstring(x);
    isCellOrCharCompatible=@(x)isCellStrCompatible(x)||isCharCompatible(x);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addRequired(argParser,'functionList',@(x)isCellOrCharCompatible(x));
        addRequired(argParser,'codeInfo',@(x)isa(x,'polyspace.internal.codeinsight.parser.CodeInfo'));
        addRequired(argParser,'globalInfo');
        addParameter(argParser,'Debug',false,@(x)isa(x,'logical'));
        addParameter(argParser,'HarnessName',"codeharness",@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'OutputDir',"",@(x)isCellOrCharCompatible(x));
    end
    argParser.parse(functionList,codeInfo,globalInfo,varargin{:});

    functionList=string(functionList);
    if isempty(functionList)
        warning("No functions to extract");
        return;
    end
    outputDir=string(argParser.Results.OutputDir);
    if~isempty(outputDir)&&~isfolder(outputDir)
        mkdir(outputDir);
    end

    srcFile=string(fullfile(outputDir,string(argParser.Results.HarnessName)+".c"));
    headerFile=string(fullfile(outputDir,string(argParser.Results.HarnessName)+".h"));



    globalFunctionInfoList=globalInfo.FunInfo(ismember([globalInfo.FunInfo.Name],functionList));


    funMap=containers.Map;

    function globalAccesses=getVariableAccesses(fun)
        if funMap.isKey(fun.Name)


            globalAccesses=funMap(fun.Name);
        else

            globalAccesses=union(string([fun.GlobalRead.Name]),string([fun.GlobalWrite.Name]));
            if~isequal(fun.Callee,polyspace.internal.codeinsight.analyzer.FunInfo.empty)

                for cidx=1:numel(fun.Callee)
                    globalAccesses=union(globalAccesses,string(getVariableAccesses(fun.Callee(cidx))));
                end
            end


            funMap(fun.Name)=globalAccesses;
        end
    end

    variablesToExtract=string([]);
    for gF=globalFunctionInfoList
        variablesToExtract=union(variablesToExtract,getVariableAccesses(gF));
    end


    functionsToExtract=string(funMap.keys);

    if argParser.Results.Debug
        fprintf("Extracting function: %s\n",functionsToExtract);
        fprintf("Extracting variable: %s\n",variablesToExtract);
    end



    functionInfoList=codeInfo.Functions(ismember([codeInfo.Functions.Name],functionsToExtract));

    definedFunctionList=functionInfoList([functionInfoList.IsDefined]==true);

    fileList=[definedFunctionList.DefinitionFile];
    undefinedFunctionList=functionInfoList([functionInfoList.IsDefined]==false);
    extractedFunctionDefinition=arrayfun(@(x)(polyspace.internal.codeinsight.harness.extractCode(x.DefinitionBlock)),definedFunctionList);
    stubbedFunctionDefinition=string([]);


    variableInfoList=polyspace.internal.codeinsight.parser.VarInfo.empty;
    if~isempty(codeInfo.Variables)
        variableInfoList=codeInfo.Variables(ismember([codeInfo.Variables.Name],variablesToExtract));
    end
    definedVariableList=variableInfoList([variableInfoList.IsDefined]==true);
    fileList=union(fileList,[definedVariableList.DefinitionFile]);
    undefinedVariableList=variableInfoList([variableInfoList.IsDefined]==false);
    extractedVariableDefinition=arrayfun(@(x)(polyspace.internal.codeinsight.harness.extractCode(x.DefinitionBlock)),definedVariableList);
    stubbedVariableDefinition=string([]);



    if~isempty(undefinedFunctionList)||~isempty(undefinedVariableList)
        stubInfo=polyspace.internal.codeinsight.stubber.generateStubFromCodeInfo(codeInfo);

        stubbedVariableDefinition=string([]);
        if~isempty(stubInfo.variablesStubObjs)
            variableToStub=stubInfo.variablesStubObjs(ismember([stubInfo.variablesStubObjs.Name],variablesToExtract));
            stubbedVariableDefinition=[variableToStub.Definition];
        end

        stubbedFunctionDefinition=string([]);
        if~isempty(stubInfo.functionStubObjs)
            functionToStub=stubInfo.functionStubObjs(ismember([stubInfo.functionStubObjs.Name],functionsToExtract));
            stubbedFunctionDefinition=arrayfun(@(x)x.getDefinition(),functionToStub);
        end
    end


    code="#include """+argParser.Results.HarnessName+".h"""+newline+newline;
    if~isempty(extractedVariableDefinition)
        code=code+...
        "/**********************************"+newline+...
        " *      VARIABLE DEFINITIONS      *"+newline+...
        " **********************************/"+newline+newline+...
        extractedVariableDefinition.join(newline)+newline+newline;
    end
    if~isempty(stubbedVariableDefinition)
        code=code+...
        "/**********************************"+newline+...
        " *  STUBBED VARIABLE DEFINITIONS  *"+newline+...
        " **********************************/"+newline+newline+...
        stubbedVariableDefinition.join(newline)+newline+newline;
    end
    if~isempty(extractedFunctionDefinition)
        code=code+...
        "/**********************************"+newline+...
        " *      FUNCTION DEFINITIONS      *"+newline+...
        " **********************************/"+newline+newline+...
        extractedFunctionDefinition.join(newline)+newline+newline;
    end
    if~isempty(stubbedFunctionDefinition)
        code=code+...
        "/**********************************"+newline+...
        " *  STUBBED FUNCTION DEFINITIONS  *"+newline+...
        " **********************************/"+newline+newline+...
        join([stubInfo.functionStubObjs.extraGlobal],newline)+newline+newline+...
        stubbedFunctionDefinition.join(newline)+newline+newline;
    end
    fid=fopen(srcFile,"w");
    fprintf(fid,"%s",code);
    fclose(fid);


    function aggregateHeaders(fid,includes)
        if isempty(includes)
            return;
        end
        nIncludes=numel(includes);
        for iIdx=1:nIncludes
            if~isempty(includes(iIdx).Includes)
                comment="/*****************"+newline+...
                " *  Included from: %s"+newline+...
                " *****************/"+newline;
                fprintf(fid,comment,includes(iIdx).Path);
                aggregateHeaders(fid,includes(iIdx).Includes);
            end
            comment="/*************************"+newline+...
            " *  Original header file: %s"+newline+...
            " *************************/"+newline;
            fprintf(fid,comment,includes(iIdx).Path);
            fprintf(fid,"%s",string(fileread(includes(iIdx).Path))+newline);
        end
    end

    fid=fopen(headerFile,"w");
    try
        for f=fileList
            aggregateHeaders(fid,f.Includes);
        end
    catch ME
        fclose(fid);
        rethrow(ME);
    end


    removeIncludeLines(headerFile);


    undeclaredFunctions=codeInfo.Functions(ismember([codeInfo.Functions.Name],functionList));
    undeclaredFunctions=undeclaredFunctions([undeclaredFunctions.IsDeclared]==false);
    if~isempty(undeclaredFunctions)
        declarations=...
        "/**********************************"+newline+...
        " *   HARNESS FUNCTION DECLARATION *"+newline+...
        " **********************************/"+newline+newline+...
        join([undeclaredFunctions.Signature],";"+newline)+";"+newline+...
        newline;
        fprintf(fid,"%s",declarations);
    end
    fclose(fid);



    parseData=polyspace.internal.codeinsight.parser.parse('SourceFiles',[srcFile,headerFile]);
    if isfield(parseData,'Errors')&&~isempty(parseData.Errors)
        error(parseData.Errors);
    end


    unusedFunctionList=parseData.Info.Functions([parseData.Info.Functions.IsDefined]==false&[parseData.Info.Functions.IsDeclared]==true);
    lineToRemove=[unusedFunctionList.DeclarationLine];
    unusedVariableList=parseData.Info.Variables([parseData.Info.Variables.IsDefined]==false&[parseData.Info.Variables.IsDeclared]==true);
    lineToRemove=[lineToRemove,[unusedVariableList.DeclarationLine]];


    tmpDir=tempname(fullfile(tempdir,'PolyspaceHarness'));
    if~isfolder(tmpDir)
        mkdir(tmpDir);
        if argParser.Results.Debug
            fprintf(1,'### Debug: use temporary folder: %s\n',tmpDir);
        end
    end
    polyspace.internal.codeinsight.analyzer.analyze('SourceFiles',[srcFile,headerFile],'ResultsDir',tmpDir,'MacroInvocation',true);
    dbRes=tmpDir;
    s=what(outputDir);
    unused=polyspace.internal.codeinsight.harness.extractUnusedDefinition(dbRes,fullfile(string(s.path),string(argParser.Results.HarnessName)+".h"));

    lineToRemove=sort(unique([lineToRemove,unused.linesToRemove]),'descend');
    hContent=split(string(fileread(headerFile)),newline);
    if argParser.Results.Debug
        copyfile(headerFile,headerFile+".bak1");
    end
    for l=lineToRemove
        hContent(l)=[];
    end
    hfile=fopen(headerFile,'w');
    fprintf(hfile,"%s",hContent.join(newline)+newline);
    fclose(hfile);
    if argParser.Results.Debug
        copyfile(headerFile,headerFile+".bak2");
    end
    removeTrailingLines(headerFile);
end

function removeTrailingLines(filename)
    filecontent=fileread(filename);
    newcontent=join(string(deblank(split(filecontent,newline))),newline);
    newcontent=regexprep(newcontent,'\n\n+','\n\n');
    fid=fopen(filename,'w');
    fwrite(fid,newcontent);
    fclose(fid);
end

function removeIncludeLines(filename)
    filecontent=fileread(filename);
    newcontent=regexprep(filecontent,' *\t*#include *\t*("(.*?)"|<(.*?)>)',"");
    fid=fopen(filename,'w');
    fwrite(fid,newcontent);
    fclose(fid);
end
