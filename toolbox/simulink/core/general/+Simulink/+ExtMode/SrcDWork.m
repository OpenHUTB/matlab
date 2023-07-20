classdef SrcDWork<dynamicprops
    properties
        BlockPath;
        DWorkName;
        SSID;
        Description;
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
        function this=SrcDWork(bpath,name,ssid,desc,dtype,dims,complex,ts)
            this.BlockPath=bpath;
            this.DWorkName=name;
            this.SSID=ssid;
            this.Description=desc;
            this.DataType=dtype;
            this.Dimensions=dims;
            this.IsComplex=complex;
            this.Timeseries=ts;
        end
    end
end
