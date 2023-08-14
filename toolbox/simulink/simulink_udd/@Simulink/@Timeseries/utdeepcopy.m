function utdeepcopy(h,hout,varargin)




    hout.('tsValue')=h.tsValue;
    if isa(hout.Data,'embedded.fi')&&~isempty(hout.tsValue.Storage_)&&...
        ~license('test','Fixed_Point_Toolbox')
        hout.('tsValue').BeingBuilt=true;
        hout.('tsValue').Data=[];
        hout.('TsValue').Storage_.Data=[];
        hout.('tsValue').BeingBuilt=false;
    end

    hout.BlockPath=h.BlockPath;
    hout.PortIndex=h.PortIndex;
    hout.ParentName=h.ParentName;
    hout.SignalName=h.SignalName;
    hout.RegionInfo=h.RegionInfo;
    hout.ValueDimensions=h.ValueDimensions;
