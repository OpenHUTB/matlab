classdef(Abstract)SharedSurfaceAnalysis<handle

    methods(Access={?em.SurfaceAnalysis,?rfpcb.SurfaceAnalysis})
        [current,Points,hfig]=currentd(obj,freq,flag,scale,port_ex);
        [charge,Points,hfig]=charged(obj,freq,flag,scale,port_ex);
        [charges,Points,hfig]=chargem(obj,frequency,flag,region,scale,port_ex);
        [currents,Points,hfig]=currentm(obj,frequency,flag,region,...
        scale,type,vector,port_ex);
        [clrbarHdl,axesHdl,hfig]=surfaceplot(obj,data,region,scale,vectorindex,currentval);
        [clrbarHdl,axesHdl,hfig]=volumeplot(obj,data,scale);
        parseobj=surfaceparser(obj,iputdata,funName);
    end
end