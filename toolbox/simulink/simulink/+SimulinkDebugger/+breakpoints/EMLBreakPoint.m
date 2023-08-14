classdef EMLBreakPoint<SimulinkDebugger.breakpoints.Breakpoint



    properties
        condition_;
        value_;
        index_;
        sfId_;
        lineNumber_;
        isHit_;
    end
    methods
        function this=EMLBreakPoint(breakPointIndex,sfId,type,fullBlockPathToTopModel,lineNumber,numHits,condition,isEnabled,isHit)
            this.type_=type;
            this.hits_=numHits;
            this.condition_=condition;
            this.id_=breakPointIndex;
            this.sfId_=sfId;
            this.fullBlockPathToTopModel_=fullBlockPathToTopModel;
            this.enable_=isEnabled;
            this.zbreakpoint_=[];
            this.lineNumber_=lineNumber;
            this.isHit_=isHit;
        end
    end
end