

classdef StateflowSimulinkFunctionInputDatatypeConstraint<...
    slci.compatibility.StateflowInputDatatypeConstraint

    methods

        function out=getDescription(aObj)%#ok
            out=['The datatype of the arguments to a Simulink function '...
            ,'in Stateflow should match the datatype of '...
            ,'the inports and outports of the Function-Call Subsystem '...
            ,'which defines the Simulink function.'];
        end


        function obj=StateflowSimulinkFunctionInputDatatypeConstraint
            obj.setEnum('StateflowSimulinkFunctionInputDatatype');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getInportDatatype(~,aAst)
            ssBlkHandle=aAst.getSLFunctionSSHandle();
            ssBlkPortDatatype=get_param(ssBlkHandle,'CompiledPortDataTypes');
            out=ssBlkPortDatatype.Inport;
        end


        function out=getOutportDatatype(~,aAst)
            ssBlkHandle=aAst.getSLFunctionSSHandle();
            ssBlkPortDatatype=get_param(ssBlkHandle,'CompiledPortDataTypes');
            out=ssBlkPortDatatype.Outport;
        end
    end
end
