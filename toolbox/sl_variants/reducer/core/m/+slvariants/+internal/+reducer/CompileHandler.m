classdef(Sealed,Hidden)CompileHandler<handle





    methods
        function obj=CompileHandler()
        end

        function setReductionInfo(obj,redInfoObj)
            obj.Model=redInfoObj.getReducedModelName();
            obj.IsSimCompileMode=redInfoObj.isSimCompileMode();
        end

        function compile(obj)
            if obj.IsSimCompileMode
                obj.updateDiagram();
            else
                obj.compileForCodegen();
            end
        end
    end

    methods(Access=private)
        function updateDiagram(obj)
            slvariants.internal.reducer.log(['Compile the model ',obj.Model]);
            set_param(obj.Model,'SimulationCommand','Update');
        end

        function compileForCodegen(obj)
            slvariants.internal.reducer.log(['Compile the model for codegen ',obj.Model]);
            feval(obj.Model,[],[],[],'compileForCodegen');
            feval(obj.Model,[],[],[],'term');
        end
    end

    properties(Access=private)
        Model(1,:)char;
        IsSimCompileMode(1,1)logical;
    end
end
