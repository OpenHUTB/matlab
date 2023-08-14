classdef SFBreakPoint<SimulinkDebugger.breakpoints.Breakpoint



    properties
        condition_;
        value_;
        index_;
        sfId_;
        sfObjectType_;
        isHit_;
    end
    methods
        function this=SFBreakPoint(breakPointIndex,sfId,fullBlockPathToTopModel,type,numHits,condition,isEnabled,sfObjectType,isHit)
            this.type_=type;
            this.hits_=numHits;
            this.condition_=condition;
            this.id_=breakPointIndex;
            this.sfId_=sfId;
            this.fullBlockPathToTopModel_=fullBlockPathToTopModel;
            this.enable_=isEnabled;
            this.sfObjectType_=sfObjectType;
            this.zbreakpoint_=[];
            this.isHit_=isHit;
        end
    end
end