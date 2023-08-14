



classdef StateflowTruthTableInputDatatypeConstraint<...
    slci.compatibility.StateflowInputDatatypeConstraint

    methods

        function out=getDescription(aObj)%#ok
            out=['The datatype of the arguments to a truth table '...
            ,'in Stateflow should match the datatype of '...
            ,'the input and output arguments defined in the Truth table.'];
        end


        function obj=StateflowTruthTableInputDatatypeConstraint
            obj.setEnum('StateflowTruthTableInputDatatype');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getInportDatatype(~,aAst)
            ttObj=aAst.ParentChart.getTruthTableObject(aAst.fSfId);
            ttUDDObj=ttObj.getUDDObject();
            children=ttUDDObj.find('-isa','Stateflow.Data');
            data=children(arrayfun(@(x)strcmpi(x.Scope,'Input'),children));
            out=arrayfun(@(x)(x.CompiledType),data,...
            'UniformOutput',false);
        end


        function out=getOutportDatatype(~,aAst)
            ttObj=aAst.ParentChart.getTruthTableObject(aAst.fSfId);
            ttUDDObj=ttObj.getUDDObject();
            children=ttUDDObj.find('-isa','Stateflow.Data');
            data=children(arrayfun(@(x)strcmpi(x.Scope,'Output'),children));
            out=arrayfun(@(x)(x.CompiledType),data,...
            'UniformOutput',false);
        end
    end
end
