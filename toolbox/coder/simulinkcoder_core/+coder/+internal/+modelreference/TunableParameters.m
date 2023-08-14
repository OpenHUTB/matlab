


classdef TunableParameters<handle
    properties(Access=private)
        Parameters=[];
CodeInfo
ModelInterface
ModelInterfaceUtils
    end


    methods(Access=public)
        function this=TunableParameters(codeInfo,modelInterfaceUtils)
            this.CodeInfo=codeInfo;
            this.ModelInterfaceUtils=modelInterfaceUtils;
            this.ModelInterface=this.ModelInterfaceUtils.getModelInterface;
            this.getTunableVariables;
        end


        function params=getParameters(this)
            params=this.Parameters;
        end


        function status=hasParameter(this)
            status=~isempty(this.Parameters);
        end
    end


    methods(Access=private)
        function getTunableVariables(this)
            if isfield(this.ModelInterface,'Parameters')
                params=coder.internal.modelreference.Utilities.getFieldData(this.ModelInterface,'Parameters');
                params=Simulink.ModelReference.ProtectedModel.removeProtectedParams(this.ModelInterface.Name,params);
                numberOfParameters=length(params);
                paramsFromCodeInfo=this.CodeInfo.Parameters;
                identifiers=get(paramsFromCodeInfo,'GraphicalName');
                mask=false(length(identifiers),1);

                for paramIdx=1:numberOfParameters
                    param=params{paramIdx};
                    if param.Tunable
                        paramIdentifier=param.Identifier;
                        codeInfoIdx=find(strcmp(identifiers,paramIdentifier),1);
                        found=~isempty(codeInfoIdx);
                        if~isempty(found)
                            mask(codeInfoIdx)=found;
                        end
                    end
                end


                this.Parameters=this.CodeInfo.Parameters(mask);
            end
        end
    end
end
