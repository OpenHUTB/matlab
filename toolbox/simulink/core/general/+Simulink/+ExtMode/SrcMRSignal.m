classdef SrcMRSignal<dynamicprops
    properties
        BlockPath;
        PortIndex;
        SigName;
        DataType;
        Dimensions;
        IsComplex;
        Timeseries;
    end
    methods
        function this=setprop(this,propName,propVal)
            this.(propName)=propVal;
        end
        function propval=getprop(this,propName)
            propval=this.(propName);
        end
        function this=SrcMRSignal(bpath,pindex,name,dtype,dims,complex,ts)
            this.BlockPath=Simulink.BlockPath(bpath);
            this.PortIndex=pindex;
            this.SigName=name;
            this.DataType=dtype;
            this.Dimensions=dims;
            this.IsComplex=complex;
            this.Timeseries=ts;
        end
    end
end
