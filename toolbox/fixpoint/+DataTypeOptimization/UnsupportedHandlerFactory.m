classdef UnsupportedHandlerFactory




    methods(Static)
        function unsupportedHandler=getHandler(model,sud,options)

            if isequal(options.Verbosity,DataTypeOptimization.VerbosityLevel.Silent)
                unsupportedHandler=DataTypeOptimization.UnsupportedBlocksHandler(model,sud);

            else
                logger=DataTypeOptimization.MessageLogger(options.Verbosity,options.VerbosityStream);
                unsupportedHandler=DataTypeOptimization.VerboseUnsupportedBlocksHandler(model,sud,logger);

            end
        end

    end
end