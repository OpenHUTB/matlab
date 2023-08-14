classdef LUTMemoryUsageCalculator















    properties(Hidden)
        Calculator=FunctionApproximation.internal.LUTMemoryUsageCalculator()
        StopCompileOnExit=true
    end

    properties
        FindOptions Simulink.internal.FindOptions=Simulink.FindOptions(...
        'RegExp',0,...
        'CaseSensitive',1,...
        'FollowLinks',0,...
        'LookUnderMasks','All',...
        'IncludeCommented',0,...
        'SearchDepth',-1,...
        'LoadFullyIfNeeded',1)
    end

    methods
        function this=LUTMemoryUsageCalculator()
            FunctionApproximation.internal.Utils.licenseCheck();


            if Simulink.internal.useFindSystemVariantsMatchFilter()




                this.FindOptions.MatchFilter=@Simulink.match.activeVariants;
            else



                this.FindOptions.Variants='ActiveVariants';
            end
        end

        function memoryUsageTable=lutmemoryusage(this,path)
            [isValid,diagnostic]=FunctionApproximation.internal.Utils.isBlockPathValid(path);
            if~isValid
                error(struct('message',diagnostic.getReport,'identifier',diagnostic.identifier,'stack',diagnostic.stack));
            end

            if this.FindOptions.IncludeCommented
                throwAsCaller(MException(message("SimulinkFixedPoint:functionApproximation:uncommentedBlocksOnly")));
            end

            if Simulink.internal.useFindSystemVariantsMatchFilter()

                if isempty(this.FindOptions.MatchFilter)||...
                    ~strcmp(func2str(this.FindOptions.MatchFilter),...
                    'Simulink.match.activeVariants')
                    throwAsCaller(MException(message("SimulinkFixedPoint:functionApproximation:activeVariantsOnly")));
                end
            else


                this.FindOptions.MatchFilter=[];
                if strcmp(this.FindOptions.Variants,'AllVariants')
                    throwAsCaller(MException(message("SimulinkFixedPoint:functionApproximation:activeVariantsOnly")));
                end
            end

            this.Calculator.FindOptions=this.FindOptions;
            this.Calculator.StopCompileOnExit=this.StopCompileOnExit;

            memoryUsageTable=memoryusage(this.Calculator,path);
            if isempty(memoryUsageTable)
                error(message('SimulinkFixedPoint:functionApproximation:lutNotFoundForMemoryCalculation'))
            end
        end

        function struct(this)
            error(message('SimulinkFixedPoint:functionApproximation:cannotConvertToStruct',class(this)));
        end
    end
end
