classdef VariableSpecification<DataTypeOptimization.Specifications.OptimizationSpecification



    methods

        function str=toString(this)
            str=sprintf("[%s::%s]",this.Element.Workspace,this.Element.Name);
        end

        function dataTypeStr=getDataTypeStr(this)
            dataTypeStr=this.Element.Value.DataType;
        end

        function setUniqueID(this,varargin)
            p=inputParser();
            p.KeepUnmatched=true;
            p.addParameter('Model','');
            p.parse(varargin{:});
            validateattributes(p.Results.Model,{'char','string'},{'scalartext','nonempty'},'setUniqueID','model');
            model=p.Results.Model;
            elementName=this.Element.Name;
            workspaceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Model;
            if isequal(this.Element.Workspace,'global-workspace')
                workspaceType=SimulinkFixedPoint.AutoscalerVarSourceTypes.Base;
            end

            dataObject=slResolve(this.Element.Name,model,'variable');


            validateattributes(dataObject,{'Simulink.Parameter','Simulink.NumericType'},{'scalar','nonempty'},'setUniqueID','dataObject');
            if isa(dataObject,'Simulink.Parameter')
                dataObjectWrapper=SimulinkFixedPoint.ParameterObjectWrapperCreator.getWrapper(...
                dataObject,elementName,model);
            elseif isa(dataObject,'Simulink.NumericType')
                dataObjectWrapper=SimulinkFixedPoint.NamedTypeObjectWrapperCreator.getWrapper(...
                dataObject,elementName,model,workspaceType);
            end


            this.UniqueID=[];
            if~isempty(dataObjectWrapper)
                dh=fxptds.SimulinkDataArrayHandler;
                paramData=struct('Object',dataObjectWrapper,'ElementName',elementName);
                this.UniqueID=dh.getUniqueIdentifier(paramData);
            end
        end
    end

end

