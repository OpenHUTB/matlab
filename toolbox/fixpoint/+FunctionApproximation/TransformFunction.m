classdef(Sealed)TransformFunction<handle





    properties(Hidden,SetAccess=protected)
        Transform;
        Filename;
        TypesTable;
        Solution FunctionApproximation.LUTSolution;
    end

    properties(SetAccess=protected)
        Problem FunctionApproximation.ClassregProblem;
    end

    methods
        function this=TransformFunction(filename,x,dtStruct)
            assert(nargin==3,message('MATLAB:minrhs'));

            [success,diagnostic,loadedFile]=FunctionApproximation.internal.Utils.validateClassregMatFile(filename);
            throwError(this,success,diagnostic);

            [success,diagnostic]=FunctionApproximation.internal.Utils.validateClassregDataTypeStruct(dtStruct);
            throwError(this,success,diagnostic);


            this.Filename=filename;
            this.TypesTable=dtStruct;
            [inputType,outputType]=getDataTypes(this);

            this.Problem=FunctionApproximation.ClassregProblem(loadedFile,x,inputType,outputType);
        end

        function outputTypeStruct=approximate(this)
            this.Solution=this.Problem.solve();
            lutName=split(this.Filename,'.');
            lutFcnString=[lutName{1},'_lookup'];
            docObj=approximate(this.Solution,'Name',lutFcnString);
            docObj.smartIndentContents;
            this.TypesTable.LookupTableFunction=['@',lutFcnString];

            outputTypeStruct=this.TypesTable;
        end

        function varargout=compare(this)
            [varargout{1},varargout{2}]=compare(this.Solution);
        end
    end

    methods(Hidden)

        function[inputType,outputType]=getDataTypes(this)
            inputType=this.TypesTable.XDataType;

            outputType=numerictype('double');

            if isfield(this.TypesTable,'TransformedScoreDataType')
                outputType=this.TypesTable.TransformedScoreDataType;
            elseif isfield(this.TypesTable,'YFitDataType')
                outputType=this.TypesTable.YFitDataType;
            end
        end

        function throwError(~,isValid,diagnostic)
            if~isValid
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end
        end
    end
end


