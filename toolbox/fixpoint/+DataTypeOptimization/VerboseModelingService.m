classdef VerboseModelingService<DataTypeOptimization.ModelingService&DataTypeOptimization.VerboseActions





    methods
        function this=VerboseModelingService(environmentProxy,logger)

            this=this@DataTypeOptimization.VerboseActions(logger);

            this=this@DataTypeOptimization.ModelingService(environmentProxy);
        end

        function[problemPrototype,baselineSimOut,baselineRunID]=modelProblem(this,opt)


            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:modelingOptimizationProblem').getString,DataTypeOptimization.VerbosityLevel.Moderate);
            [problemPrototype,baselineSimOut,baselineRunID]=modelProblem@DataTypeOptimization.ModelingService(this,opt);
        end

        function dv=getDecisionVariables(this,options,allGroups,groupRanges)


            this.publish(message('SimulinkFixedPoint:dataTypeOptimization:constructingDecisionVariables').getString,DataTypeOptimization.VerbosityLevel.High);
            dv=getDecisionVariables@DataTypeOptimization.ModelingService(this,options,allGroups,groupRanges);
        end

    end
end