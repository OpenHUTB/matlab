classdef(Sealed)ClassregProblem<handle





    properties
        FunctionToApproximate;
        NumberOfInputs;
        InputTypes;
        InputLowerBounds;
        InputUpperBounds;
        OutputType;
    end

    properties(Hidden,SetAccess=protected)
        Problem FunctionApproximation.Problem;
        TransformFunction;
    end

    properties(SetAccess=protected)
        Options;
    end

    methods
        function this=ClassregProblem(loadedFile,x,inputType,outputType)

            functionToApproximate=this.getTransformFunctionHandle(loadedFile);

            this.FunctionToApproximate=functionToApproximate;
            this.InputTypes=inputType.numerictype;
            this.InputLowerBounds=min(x(:));
            this.InputUpperBounds=max(x(:));
            this.OutputType=outputType.numerictype;

            this.Problem=makeProblem(this);
        end
    end

    methods(Access={?FunctionApproximation.TransformFunction})

        function problem=makeProblem(this)

            absTol=double(this.OutputType.Slope);

            this.Options=FunctionApproximation.Options('AbsTol',absTol,'ApproximateSolutionType','MATLAB','SaturateToOutputType',true,'Display',0);

            problem=FunctionApproximation.Problem(this.FunctionToApproximate,"InputLowerBounds",this.InputLowerBounds,...
            "InputTypes",this.InputTypes,"InputUpperBounds",this.InputUpperBounds,"Options",this.Options,"OutputType",this.OutputType);

            this.NumberOfInputs=problem.NumberOfInputs;
        end

        function functionToApproximate=getTransformFunctionHandle(this,loadedFile)

            if isfield(loadedFile.compactStruct,'ResponseTransform')
                this.TransformFunction=char(loadedFile.compactStruct.ResponseTransformFull);
            else
                this.TransformFunction=char(loadedFile.compactStruct.ScoreTransformFull);
            end
            functionToApproximate=getFunctionToApproximate(this);
        end

        function solution=solve(this)
            solution=this.Problem.solve();
        end

        function functionHandle=getFunctionToApproximate(this)
            functionHandle=FunctionApproximation.internal.getTransformFunctionHandle(this.TransformFunction);
        end
    end
end