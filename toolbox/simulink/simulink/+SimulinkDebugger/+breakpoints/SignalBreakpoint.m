classdef SignalBreakpoint<SimulinkDebugger.breakpoints.Breakpoint




    methods
        function this=SignalBreakpoint(id,sourceHandle,bp_data,...
            fullBlockPathToTopModel)

            this.id_=id;
            this.src_=sourceHandle;
            this.type_=SimulinkDebugger.breakpoints.BreakpointType.Signal;
            this.index_=bp_data{1};
            this.condition_=bp_data{2};
            this.value_=bp_data{3};
            this.enable_=bp_data{4}==1;
            this.hits_=bp_data{6};
            this.zbreakpoint_=[];
            this.fullBlockPathToTopModel_=fullBlockPathToTopModel;
        end
    end

    properties
        condition_;
        value_;
        index_;
    end
end
