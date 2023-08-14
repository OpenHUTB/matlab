classdef BlockBreakpoint<SimulinkDebugger.breakpoints.Breakpoint




    methods
        function this=BlockBreakpoint(id,zbreakpoint,fullBlockPathToTopModel,hitCount)




            this.id_=id;
            blockPath=zbreakpoint.blockPath;
            if bdIsLoaded(zbreakpoint.modelName)



                blockPath=strrep(blockPath,'''','');
                this.src_=get_param(blockPath,'Handle');
            else
                this.src_=[];
            end
            this.blockPath_=blockPath;
            this.fullBlockPathToTopModel_=fullBlockPathToTopModel;
            this.type_=SimulinkDebugger.breakpoints.BreakpointType.Block;
            this.enable_=zbreakpoint.isEnabled;
            this.hits_=hitCount;
            this.zbreakpoint_=zbreakpoint;
        end
    end

    properties
        blockPath_;
    end
end


