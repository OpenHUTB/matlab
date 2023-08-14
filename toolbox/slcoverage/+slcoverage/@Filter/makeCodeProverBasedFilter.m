



function[filterObj,filterRules]=makeCodeProverBasedFilter(model,results,varargin)


    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end


    [status,msgId]=SlCov.CoverageAPI.checkPolyspaceLicense;
    if status==0
        error(message(msgId));
    end


    isNonEmptyScalarString=@(x)isstring(x)&&isscalar(x)&&strlength(x)>0;
    isNonEmptyChar=@(x)~isempty(x)&&ischar(x)&&size(x,1)==1;
    isNonEmptyCharCompatible=@(x)isNonEmptyChar(x)||isNonEmptyScalarString(x);


    narginchk(2,4);
    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addRequired(argParser,'model',@(x)is_simulink_handle(x)||isNonEmptyCharCompatible(x));
        addRequired(argParser,'results',@(x)validateattributes(x,{'char','string'},{'scalartext','nonempty'}));
        addOptional(argParser,'SimulationMode','xil',@(x)any(validatestring(x,slcoverage.Selector.SupportedXILModes)));
    end

    parse(argParser,model,results,varargin{:});

    if isa(argParser.Results.model,'double')
        model=get_param(bdroot(model),'Name');
    else
        tok=strsplit(char(model),'/');
        model=tok{1};
        if~bdIsLoaded(model)
            error(message('Simulink:utility:modelNotLoaded',model));
        end
    end

    if~isfile(results)
        error(message('Slvnv:codecoverage:CPFilterCannotFindResFile',results));
    end




    codeTrFile=slcoverage.Selector.checkCodeCompile(model,argParser.Results.SimulationMode);
    if isempty(codeTrFile)||~isfile(codeTrFile)
        error(message('Slvnv:codecoverage:CPFilterCannotFindCodeTrFile',model));
    end


    [~,predefRules]=slcoverage.Selector.possibleCodeSelector(model,...
    'Mode','xil',...
    'CodeTr',codeTrFile,...
    'CodeProverResults',results);

    filterObj=[];
    filterRules=[];
    if~isempty(predefRules)
        filterObj=slcoverage.Filter;
        filterRules=predefRules;
        for ii=1:numel(predefRules)
            filterObj.addRule(predefRules(ii));
        end
    end