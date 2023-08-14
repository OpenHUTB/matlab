

classdef StateflowGraphicalFunctionInputDimensionConstraint<...
    slci.compatibility.StateflowInputDimensionConstraint
    methods

        function out=getDescription(aObj)%#ok
            out=['The dimension of the arguments to a graphical function '...
            ,'call in Stateflow should match the dimension of '...
            ,'the input and output arguments defined in the '...
            ,'graphical function.'];
        end


        function obj=StateflowGraphicalFunctionInputDimensionConstraint
            obj.setEnum('StateflowGraphicalFunctionInputDimension');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getInportDimension(~,aAst)
            gfnObj=aAst.ParentChart.getGraphicalFunctionObject(aAst.fSfId);
            children=gfnObj.getUDDObject().getChildren();
            data=children(arrayfun(@(x)(isa(x,'Stateflow.Data')...
            &&strcmpi(x.Scope,'Input')),children));
            out=arrayfun(@(x)(x.CompiledSize),data,'UniformOutput',false);
        end


        function out=getOutportDimension(~,aAst)
            gfnObj=aAst.ParentChart.getGraphicalFunctionObject(aAst.fSfId);
            children=gfnObj.getUDDObject().getChildren();
            data=children(arrayfun(@(x)(isa(x,'Stateflow.Data')...
            &&strcmpi(x.Scope,'Output')),children));
            out=arrayfun(@(x)(x.CompiledSize),data,'UniformOutput',false);
        end
    end
end
