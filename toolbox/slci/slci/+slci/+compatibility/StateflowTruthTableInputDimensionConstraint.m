



classdef StateflowTruthTableInputDimensionConstraint<...
    slci.compatibility.StateflowInputDimensionConstraint

    methods

        function out=getDescription(aObj)%#ok
            out=['The dimension of the arguments to a truth table '...
            ,'in Stateflow should match the dimension of '...
            ,'the input and output arguments defined in the Truth table.'];
        end


        function obj=StateflowTruthTableInputDimensionConstraint
            obj.setEnum('StateflowTruthTableInputDimension');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getInportDimension(~,aAst)
            ttObj=aAst.ParentChart.getTruthTableObject(aAst.fSfId);
            ttUDDObj=ttObj.getUDDObject();
            children=ttUDDObj.find('-isa','Stateflow.Data');
            data=children(arrayfun(@(x)strcmpi(x.Scope,'Input'),children));
            out=arrayfun(@(x)(x.CompiledSize),data,...
            'UniformOutput',false);
        end


        function out=getOutportDimension(~,aAst)
            ttObj=aAst.ParentChart.getTruthTableObject(aAst.fSfId);
            ttUDDObj=ttObj.getUDDObject();
            children=ttUDDObj.find('-isa','Stateflow.Data');
            data=children(arrayfun(@(x)strcmpi(x.Scope,'Output'),children));
            out=arrayfun(@(x)(x.CompiledSize),data,...
            'UniformOutput',false);
        end
    end
end
