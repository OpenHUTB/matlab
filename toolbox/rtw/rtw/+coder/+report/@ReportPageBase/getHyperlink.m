function out=getHyperlink(obj,varargin)
    linkManager=obj.getLinkManager();
    if isempty(linkManager)
        out=varargin{1};
    else
        out=linkManager.getLinkToFrontEnd(varargin{:});
    end
end
