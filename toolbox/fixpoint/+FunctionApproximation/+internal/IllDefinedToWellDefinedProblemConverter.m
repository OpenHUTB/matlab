classdef(Sealed)IllDefinedToWellDefinedProblemConverter









    properties(Constant)



        HandlerInputs={...
        'InputDimensionsValidator',{'NullModifier'};...
        'OutputTypeValidator',{'NullModifier'};...
        'HalfInInterfaceTypesValidator',{'NullModifier'};...
        'LowerBoundsDimensionsValidator',{'NullModifier'};...
        'UpperBoundsDimensionsValidator',{'NullModifier'};...
        'AllDimensionBoundValidator',{'InputBoundsModifier','InputTypeScalingModifier','CastOutputToDouble','SaturateToOutputType'};...
        'InterpolationModeNoneValidator',{'HandleVectorizationModifier'};...
        'ElementWiseOperationFunction',{'InfAndNaNProtector','SampleDataCreator'};...
        'ComplexEvaluationValidator',{'NullModifier'};...
        'ModelInfTimeValidator',{'NullModifier'};...
        'TimeInvarianceValidator',{'NullModifier'};...
        'InfEvaluationInSampleData',{'NullModifier'};...
        'NaNEvaluationInSampleData',{'NullModifier'};...
        };
    end

    methods
        function problemDefnition=convert(this,problemDefinition)
            firstHandlerNode=getHandler(this);
            msgRepo=FunctionApproximation.internal.MessageRepository(problemDefinition.Options);
            problemDefnition=firstHandlerNode.handle(problemDefinition,msgRepo);
            msgRepo.displayMessages();
        end

        function firstHandlerNode=getHandler(this)
            nHandlers=size(this.HandlerInputs,1);
            for iHandler=nHandlers:-1:1
                handler{iHandler}=FunctionApproximation.internal.WellDefinedProblemHandler();
                handler{iHandler}.setValidator(FunctionApproximation.internal.problemvalidator.(this.HandlerInputs{iHandler,1}));
                nMod=numel(this.HandlerInputs{iHandler,2});
                modifiers=repmat(FunctionApproximation.internal.problemmodifier.NullModifier,1,nMod);
                for iMod=1:nMod
                    modifiers(iMod)=FunctionApproximation.internal.problemmodifier.(this.HandlerInputs{iHandler,2}{iMod});
                end
                handler{iHandler}.setModifier(modifiers);
                if iHandler~=nHandlers
                    handler{iHandler}.setNextHandler(handler{iHandler+1});
                end
            end
            firstHandlerNode=handler{1};
        end
    end
end


