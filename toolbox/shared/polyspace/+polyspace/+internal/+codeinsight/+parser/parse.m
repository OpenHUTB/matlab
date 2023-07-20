

function res=parse(varargin)

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
        addParameter(argParser,'ConvertMacros',false,@(x)isa(x,'logical'));
    end
    argParser.parse(varargin{:});
    sourceFiles=strip(string(argParser.Results.SourceFiles));

    res=struct('Errors',[],'Info',[]);

    if isempty(sourceFiles)

        warning("Source files are empty");
        return
    end


    parsingOptions=argParser.Results.ParsingOptions;
    if isempty(parsingOptions)
        if polyspace.internal.codeinsight.utils.hasCxxSources(sourceFiles)
            lang='cxx';
        else
            lang='c';
        end
        parsingOptions=internal.cxxfe.util.getMexFrontEndOptions('lang',lang,'addMWInc',true);
    end


    includeDirs=cellstr(convertStringsToChars(argParser.Results.IncludeDirs));
    defines=cellstr(convertStringsToChars(argParser.Results.Defines));
    parsingOptions.Preprocessor.IncludeDirs=[parsingOptions.Preprocessor.IncludeDirs(:);includeDirs(:)];
    parsingOptions.Preprocessor.Defines=[parsingOptions.Preprocessor.Defines(:);defines(:)];
    cvtOpts=internal.cxxfe.il2ast.Options();
    cvtOpts.ExtractCodeInsightInfo=true;
    cvtOpts.Strategy=internal.cxxfe.il2ast.ConvertKind.GlobalSymbols;
    if argParser.Results.ConvertMacros
        cvtOpts.ConvertMacros=1;
    end
    if argParser.Results.Debug
        parsingOptions.Verbose=true;
    end

    [hFiles,cFiles]=polyspace.internal.codeinsight.utils.getSourcesAndHeaders(sourceFiles);
    if(numel(cFiles)>0)
        argFile=cFiles(1);
        extraFiles=[cFiles(2:end),hFiles];
    else
        argFile=sourceFiles(1);
        extraFiles=sourceFiles(2:end);
    end
    parsingOptions.RemoveUnneededEntities=argParser.Results.RemoveUnneededEntities;
    parsingOptions.ExtraSources=extraFiles;



    if~isempty(extraFiles)&&~startsWith(lower(parsingOptions.Language.LanguageMode),'cxx')
        parsingOptions.ExtraOptions(end+1)={'--allow_ints_same_representation'};
    end

    parseEnv=internal.cxxfe.il2ast.Env(parsingOptions);
    parseEnv.parseFile(argFile,cvtOpts);

    [msg,failures]=evalc('internal.cxxfe.util.printFEMessages(parseEnv.getMessages(), false)');
    if failures
        res.Errors=msg;
        return;
    end

    if argParser.Results.OutputAST
        res.AST=parseEnv.Ast;
    end

    res.Info=polyspace.internal.codeinsight.parser.processAST(parseEnv.Ast);

    if argParser.Results.Debug
        res.Info.print;
    end
end
