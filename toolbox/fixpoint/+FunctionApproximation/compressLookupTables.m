function result=compressLookupTables(sud,varargin)















































    sud=convertStringsToChars(sud);
    parser=inputParser();
    parser.KeepUnmatched=true;
    parser.addRequired('SUD',@ischar);
    parser.parse(sud);
    sud=parser.Results.SUD;
    topModel=bdroot(sud);


    harwareConstraint=SimulinkFixedPoint.AutoscalerConstraints.HardwareConstraintFactory.getConstraint(topModel);
    wls=harwareConstraint.ChildConstraint.SpecificWL;
    multiWord=double(harwareConstraint.Multiword.WordLength);
    [~,finalWLs]=SimulinkFixedPoint.AutoscalerConstraints.mergeVectors(wls,1:multiWord);


    calculator=FunctionApproximation.LUTMemoryUsageCalculator();


    parser.addOptional('WordLengths',finalWLs);
    parser.addOptional('Display',true);
    parser.addOptional('FindOptions',calculator.FindOptions);
    parser.parse(sud,varargin{:});
    parseResults=parser.Results;


    findOptions=parseResults.FindOptions;
    toDisplay=parseResults.Display;
    wordLengths=parseResults.WordLengths;




    options=FunctionApproximation.Options('AbsTol',0,'RelTol',0,'Display',toDisplay,'WordLengths',wordLengths,'MaxNumDim',30);


    compileHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(topModel);
    compileHandler.start();
    c=onCleanup(@()stop(compileHandler));


    calculator.FindOptions=findOptions;
    calculator.FindOptions.IncludeCommented=false;
    if Simulink.internal.useFindSystemVariantsMatchFilter()




        calculator.FindOptions.MatchFilter=@Simulink.match.activeVariants;
    else



        calculator.FindOptions.Variants='ActiveVariants';
    end
    calculator.StopCompileOnExit=false;
    try
        dataTable=calculator.lutmemoryusage(sud);
    catch err %#ok<NASGU> %Will throw an error if no LUTs
        dataTable=table.empty();
    end
    numLUTs=size(dataTable,1);
    FunctionApproximation.internal.DisplayUtils.numLUTsFound(numLUTs,options);


    solutions={};
    if~isempty(dataTable)
        FunctionApproximation.internal.DisplayUtils.displayCompressedSolutionPercentReductionHeader(options);
        blockColumnName=FunctionApproximation.internal.memoryusagetablebuilder.MemoryUsageTableBuilder.MetaData.PathsColumnName;
        strategy=FunctionApproximation.internal.solvers.getMultiLUTCompressionStrategy();
        strategy.execute(dataTable.(blockColumnName),options);
        solutions=strategy.getSolutions();
    end


    result=FunctionApproximation.LUTCompressionResult();
    result.setDataTable(dataTable);
    result.setSolutions(solutions);
    result.setSUD(sud);
    result.setDisplay(toDisplay);
    result.setFindOptions(findOptions);
    result.setWordLengths(wordLengths);
    result.setSolverOptions(options);
end
