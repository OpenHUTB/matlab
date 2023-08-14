

function createFileHarness(varargin)



    isCharCompatible=@(x)ischar(x)||(isstring(x)&&isscalar(x));
    isCellStrCompatible=@(x)iscellstr(x)||isstring(x);
    isCellOrCharCompatible=@(x)isCellStrCompatible(x)||isCharCompatible(x);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addParameter(argParser,'SourceFiles',{},@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'IncludeDirs',{},@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'Defines',{},@(x)isCellOrCharCompatible(x));
        addParameter(argParser,'ParsingOptions',[],@(x)isa(x,'internal.cxxfe.FrontEndOptions'));
        addParameter(argParser,'Debug',false,@(x)isa(x,'logical'));
        addParameter(argParser,'OutputAST',false,@(x)isa(x,'logical'));
        addParameter(argParser,'RemoveUnneededEntities',true,@(x)isa(x,'logical'));
        addParameter(argParser,'AggregatedHeaderFileName','interfaces_header.h',@(x)isCharCompatible(x));
        addParameter(argParser,'GenerateDeclarationForAllSymbols',false,@(x)isa(x,'logical'));
        addParameter(argParser,'ResultsDir','',@(x)isCharCompatible(x));
    end
    argParser.parse(varargin{:});


    parseData=polyspace.internal.codeinsight.parser.parse(...
    'SourceFiles',argParser.Results.SourceFiles,...
    'IncludeDirs',argParser.Results.IncludeDirs,...
    'Defines',argParser.Results.Defines,...
    'Debug',argParser.Results.Debug);

    if~isempty(parseData.Errors)
        error(parseData.Errors);
    end

    if~polyspace.internal.codeinsight.analyzer.globalVariableParserAnalysis

        if ismember('ResultsDir',argParser.UsingDefaults)

            resDir=tempname(fullfile(tempdir,'CodeInsight'));
            if~isfolder(resDir)
                mkdir(resDir);
                if argParser.Results.Debug
                    fprintf(1,'### Debug: use temporary folder: %s\n',resDir);
                else
                    clrObj=onCleanup(@()rmdir(resDir,'s'));
                end
            end
        else
            resDir=argParser.Results.ResultsDir;
        end

        [status,~]=polyspace.internal.codeinsight.analyzer.analyze(...
        'SourceFiles',argParser.Results.SourceFiles,...
        'IncludeDirs',argParser.Results.IncludeDirs,...
        'Defines',argParser.Results.Defines,...
        'Debug',argParser.Results.Debug,...
        'MacroInvocation',false,...
        'KeepAllFiles',true,...
        'ResultsDir',resDir);
        if status~=1
            error("Error during files analysis. Please see command window for details.");
        end


        [parseData.Info,functionList]=polyspace.internal.codeinsight.harness.extractFunctionInfo(argParser.Results.SourceFiles,resDir,parseData.Info,'MacroInvocation',false);
    else
        functionList=string([]);
        for fidx=1:numel(argParser.Results.SourceFiles)
            funs=parseData.Info.Functions;
            if~isempty(funs)
                defs=[funs.DefinitionFile];
                paths=[defs.Path];
                funObjs=parseData.Info.Functions(strcmp(strtrim(string(argParser.Results.SourceFiles(fidx))),paths));
                functionList=[functionList,[funObjs.Name]];%#ok<AGROW>
            end
        end
    end


    polyspace.internal.codeinsight.harness.generateInterfaceHeaderFile(parseData.Info,string(functionList),argParser.Results.AggregatedHeaderFileName);

end

