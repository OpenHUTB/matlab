classdef ModelBreakpoint<SimulinkDebugger.breakpoints.Breakpoint




    methods
        function this=ModelBreakpoint(id,zbreakpoint)




            this.id_=id;
            this.bpType_=zbreakpoint.bpType;
            this.src_=zbreakpoint.modelName;
            this.type_=SimulinkDebugger.breakpoints.BreakpointType.Model;
            this.enable_=zbreakpoint.isEnabled;
            this.zbreakpoint_=zbreakpoint;
        end
    end

    properties
        bpType_;
    end
end


