classdef HarnessPerfTracer<handle
    properties(Access='private')
model
op
phase
    end

    methods
        function self=HarnessPerfTracer(model,op,phase)
            assert(Simulink.harness.internal.isTracedHarnessOp(op));
            self.model=model;
            self.op=op;
            self.phase=phase;
            PerfTools.Tracer.logSimulinkData(self.op,self.model,'',self.phase,true);
        end

        function delete(self)
            PerfTools.Tracer.logSimulinkData(self.op,self.model,'',self.phase,false);
        end
    end
end