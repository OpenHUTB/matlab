

classdef StateflowGraphicalFunctionInputDatatypeConstraint<...
    slci.compatibility.StateflowInputDatatypeConstraint

    methods

        function out=getDescription(aObj)%#ok
            out=['The datatype of the arguments to a graphical function '...
            ,'call in Stateflow should match the datatype of '...
            ,'the input and output arguments defined in '...
            ,'the graphical function.'];
        end

        function obj=StateflowGraphicalFunctionInputDatatypeConstraint
            obj.setEnum('StateflowGraphicalFunctionInputDatatype');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getInportDatatype(~,aAst)

            gfnObj=aAst.ParentChart.getGraphicalFunctionObject(aAst.fSfId);
            children=gfnObj.getUDDObject().getChildren();
            data=children(arrayfun(@(x)(isa(x,'Stateflow.Data')...
            &&strcmpi(x.Scope,'Input')),children));
            out=arrayfun(@(x)(x.CompiledType),data,...
            'UniformOutput',false);
        end


        function out=getOutportDatatype(~,aAst)

            gfnObj=aAst.ParentChart.getGraphicalFunctionObject(aAst.fSfId);
            children=gfnObj.getUDDObject().getChildren();
            data=children(arrayfun(@(x)(isa(x,'Stateflow.Data')...
            &&strcmpi(x.Scope,'Output')),children));
            out=arrayfun(@(x)(x.CompiledType),data,...
            'UniformOutput',false);
        end

    end
end
