function ret=source(hw,sourceName,varargin)


















    if nargin==1
        ret=getAvailableSources(hw);
    else
        ret=getSource(hw,sourceName,varargin{:});
    end
end
