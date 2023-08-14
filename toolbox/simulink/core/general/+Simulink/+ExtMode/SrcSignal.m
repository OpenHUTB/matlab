classdef SrcSignal<dynamicprops




    properties
        BlockPath;
        GrBlockPath;
        PortIndex;
        GrPortIndex;
        SigName;
        SampleTime;
        Timeseries;
        ActSrcHandle;
    end
    methods
        function this=setprop(this,propName,propVal)
            this.(propName)=propVal;
        end
        function propval=getprop(this,propName)
            propval=this.(propName);
        end
        function this=SrcSignal(bpath,grbpath,pindex,grpindex,name,sampTime,ts,actSrcHandle)
            if nargin<8
                actSrcHandle=[];
            end
            this.BlockPath=bpath;
            this.GrBlockPath=grbpath;
            this.PortIndex=pindex;
            this.GrPortIndex=grpindex;
            this.SigName=name;
            this.SampleTime=sampTime;
            this.Timeseries=ts;
            this.ActSrcHandle=actSrcHandle;
        end
    end
end
