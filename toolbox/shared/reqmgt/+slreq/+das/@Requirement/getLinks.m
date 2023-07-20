function[incomingLinks,outgoingLinks]=getLinks(this,varargin)






    if nargout<2
        incomingLinks=this.dataModelObj.getLinks(varargin{:});
    else
        [incomingLinks,outgoingLinks]=this.dataModelObj.getLinks(varargin{:});
    end
end
