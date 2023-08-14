




function varargout=getHardwareVendorNames(targetOrProduction,varargin)
    h=coder.HardwareImplementation;
    entries=h.VendorNames(targetOrProduction);
    default=h.VendorName(targetOrProduction);

    defaultsOnly=nargin>1&&islogical(varargin{1})&&varargin{1};

    if defaultsOnly
        varargout={default};
    else
        varargout={entries,default};
    end
end
