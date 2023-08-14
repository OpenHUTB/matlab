classdef(Sealed)WellDefinedProblemHandler<handle





    properties(SetAccess=private)
        Validator(1,1)FunctionApproximation.internal.problemvalidator.ProblemDefinitionValidator=...
        FunctionApproximation.internal.problemvalidator.NullValidator
        Modifier(1,:)FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier=...
        FunctionApproximation.internal.problemmodifier.NullModifier
        NextHandler FunctionApproximation.internal.WellDefinedProblemHandler=...
        FunctionApproximation.internal.WellDefinedProblemHandler.empty;
    end

    methods
        function setNextHandler(this,handler)
            this.NextHandler=handler;
        end

        function setValidator(this,validator)
            isscalar(validator);
            this.Validator=validator;
        end

        function setModifier(this,modifier)
            this.Modifier=modifier;
        end

        function problemDefinition=handle(this,problemDefinition,messageRepository)
            success=this.Validator.validate(problemDefinition);
            if success
                for iMod=1:numel(this.Modifier)
                    setMessageRepository(this.Modifier(iMod),messageRepository);
                    problemDefinition=this.Modifier(iMod).modify(problemDefinition);
                end
                if~isempty(this.NextHandler)
                    problemDefinition=this.NextHandler.handle(problemDefinition,messageRepository);
                end
            else
                this.Validator.throwError(problemDefinition);
            end
        end
    end
end
