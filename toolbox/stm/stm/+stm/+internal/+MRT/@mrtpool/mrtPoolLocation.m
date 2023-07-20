function loc=mrtPoolLocation(varargin)




    persistent rootLocation
    if(isempty(rootLocation)&&nargin==1)
        rootLocation=varargin{1};
    end
    loc=rootLocation;
end


