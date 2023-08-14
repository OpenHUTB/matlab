




classdef FixTunableParameters<Simulink.ModelReference.Conversion.AutoFix
    properties(Access=private)
Model
TunableParameters
ConversionData
ParamsInGlobalScope
    end

    methods(Access=public)
        function this=FixTunableParameters(model,conversionData)
            this.Model=get_param(model,'Name');
            this.TunableParameters=get_param(this.Model,'TunableVars');
            this.ConversionData=conversionData;
            this.ParamsInGlobalScope=this.getParametersInGlobalScope();
        end


        function status=check(this)
            status=this.isRightClickBuildFeature()||isempty(this.TunableParameters)...
            ||isempty(this.ParamsInGlobalScope);
        end

        function fix(this)
            tunablevars2parameterobjects(this.Model,'Simulink.Parameter');
            this.cacheTunableParameterNames;
        end

        function results=getActionDescription(this)
            params=strjoin(this.ParamsInGlobalScope,', ');
            results={message('Simulink:modelReferenceAdvisor:FixTunableParameters',params)};
        end
    end

    methods(Access=private)
        function result=isRightClickBuildFeature(this)
            result=slfeature('RightClickBuild')&&this.ConversionData.ConversionParameters.RightClickBuild;
        end

        function result=getParametersInGlobalScope(this)
            params=strsplit(this.TunableParameters,',');
            isInGlobalScope=cellfun(@(x)existsInGlobalScope(this.Model,x),params);
            result=params(logical(isInGlobalScope));
        end

        function cacheTunableParameterNames(this)
            cellfun(@(x)this.ConversionData.addVariable(x),this.ParamsInGlobalScope);
        end
    end
end
