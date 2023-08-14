classdef VerboseUnsupportedBlocksHandler<DataTypeOptimization.UnsupportedBlocksHandler&DataTypeOptimization.VerboseActions




    methods
        function this=VerboseUnsupportedBlocksHandler(model,sud,logger)

            this=this@DataTypeOptimization.VerboseActions(logger);


            this=this@DataTypeOptimization.UnsupportedBlocksHandler(model,sud);

        end

        function unsupportedExist=checkUnsupported(this)

            this.publish(...
            message('SimulinkFixedPoint:dataTypeOptimization:checkUnsupported').getString,...
            DataTypeOptimization.VerbosityLevel.Moderate);
            unsupportedExist=checkUnsupported@DataTypeOptimization.UnsupportedBlocksHandler(this);

        end

        function decoupledConstructs=handleUnsupported(this,options)
            if isequal(options.AdvancedOptions.HandleUnsupported,DataTypeOptimization.UnsupportedHandlingMode.Isolate)&&...
                numel(this.UnsupportedConstructs)>0
                this.publish(...
                message('SimulinkFixedPoint:dataTypeOptimization:handleUnsupported').getString,...
                DataTypeOptimization.VerbosityLevel.High);

            end


            for cIndex=1:numel(this.UnsupportedConstructs)
                bp=Simulink.BlockPath(this.UnsupportedConstructs{cIndex}.constructName);
                disp(bp,true);

            end


            decoupledConstructs=handleUnsupported@DataTypeOptimization.UnsupportedBlocksHandler(this,options);

        end
    end


end