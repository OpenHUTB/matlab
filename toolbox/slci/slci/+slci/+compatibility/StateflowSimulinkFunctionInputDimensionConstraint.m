


classdef StateflowSimulinkFunctionInputDimensionConstraint<...
    slci.compatibility.StateflowInputDimensionConstraint
    methods

        function out=getDescription(aObj)%#ok
            out=['The size of the arguments to a Simulink function '...
            ,'in Stateflow should match the size of the inports '...
            ,'and outports of the Function-Call Subsystem '...
            ,'which defines the Simulink function.'];
        end


        function obj=StateflowSimulinkFunctionInputDimensionConstraint
            obj.setEnum('StateflowSimulinkFunctionInputDimension');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getInportDimension(~,aAst)
            ssBlkHandle=aAst.getSLFunctionSSHandle();
            ssBlkPortDims=get_param(ssBlkHandle,'CompiledPortWidths');
            out=ssBlkPortDims.Inport;
        end


        function out=getOutportDimension(~,aAst)
            ssBlkHandle=aAst.getSLFunctionSSHandle();
            ssBlkPortDims=get_param(ssBlkHandle,'CompiledPortWidths');
            out=ssBlkPortDims.Outport;
        end

    end
end
