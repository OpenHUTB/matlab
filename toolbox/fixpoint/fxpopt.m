function result=fxpopt(model,sud,varargin)

    narginchk(2,3);


    numvarargs=length(varargin);
    optArgs={fxpOptimizationOptions};
    optArgs(1:numvarargs)=varargin;
    options=optArgs{:};


    fpdLicenseCheck();

    try
        DataTypeOptimization.load_system(model);


        logger=DataTypeOptimization.MessageLogger(options.Verbosity,options.VerbosityStream);
        logger.publish(...
        message('SimulinkFixedPoint:dataTypeOptimization:startOptimization').getString,...
        DataTypeOptimization.VerbosityLevel.Moderate);


        unsupportedHandler=DataTypeOptimization.UnsupportedHandlerFactory.getHandler(model,sud,options);
        unsupportedBlocksExist=unsupportedHandler.checkUnsupported();


        engine=DataTypeOptimization.OptimizationEngineFactory.getEngine(model,sud,options,unsupportedBlocksExist);


        unsupportedHandler.handleUnsupported(options);


        result=engine.run();

    catch errDiag
        if slsvTestingHook('FXPOptimizationDebugMode')

            rethrow(errDiag);
        else

            throwAsCaller(errDiag);
        end
    end

end
