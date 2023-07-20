function output=getAdaptorSpecificInfo(h,adaptorName,funcName,varargin)




    output=h.mAdaptorRegistry.(funcName)(adaptorName,varargin{:});

end
