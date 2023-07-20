classdef(Abstract)Base<handle&matlab.mixin.Heterogeneous




    properties(SetAccess=immutable)
        Param(1,1)struct;
        Model(1,1)string;
    end

    methods
        function this=Base(param,model)
            narginchk(2,2);
            this.Param=param;
            this.Model=model;
        end


        function value=getOverrideValue(this)
            if this.isNonSLParamOverridingSLParam
                value=this.getSimulinkParameter;
                value.Value=this.getParamValue;
            else
                value=this.getParamValue;
            end
        end

        function value=getDsmOverrideValue(this)
            currentValue=this.getCurrentValue;
            assert(isa(currentValue,'Simulink.Signal'));
            assert(~currentValue.CoderInfo.HasContext,'Expected objects without context');
            value=currentValue.copy;
            value.LoggingInfo.DataLogging=true;
        end

        function slParam=getSimulinkParameter(this)
            currentValue=this.getCurrentValue;
            assert(isa(currentValue,'Simulink.Parameter'));
            w=warning("off","Simulink:Data:CopyWillNotPreserveCodeProps");
            restoreWarnings=onCleanup(@()warning(w));
            slParam=currentValue.copy;
        end


        function bool=isNonSLParamOverridingSLParam(this)
            bool=~isa(this.getParamValue,'Simulink.Parameter')&&...
            isa(this.getCurrentValue,'Simulink.Parameter');
        end

        function workspace=getWorkspace(~)
            workspace='base';
        end

        function workspace=getVariableWorkspace(~)
            workspace='global-workspace';
        end

        function property=getSimInProperty(~)
            property=cell.empty;
        end

        value=getCurrentValue(this);
    end

    methods(Access=protected)

        function value=getParamValue(this)
            if this.Param.IsDerived
                value=this.Param.RuntimeValue;
            elseif this.Param.IsOverridingChar
                value=this.Param.Value;
            else
                value=evalin(this.getWorkspace,this.Param.Value);
            end
        end

        function property=getSimInVariable(this)
            property=arrayfun(@(r)...
            Simulink.Simulation.Variable(r.Param.Name,r.getOverrideValue,...
            'workspace',r.getVariableWorkspace),this);
        end
    end

    methods(Static,Access=protected)
        function defaultObject=getDefaultScalarElement
            defaultObject=stm.internal.VariableReader.BaseWorkspace;
        end
    end
end
