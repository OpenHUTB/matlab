function AXIMasterObj=socAXIMaster(varargin)























































    if ischar(varargin{1})
        vendor=varargin{1};
    elseif isa(varargin{1},'ioplayback.hardware.Base')
        vendor=soc.internal.getVendor(varargin{1});
    else
        error(message('soc:msgs:InvalidInputForSoCAXIMaster'));
    end


    AXIMasterObj=aximanager(vendor,varargin{2:end});
end
