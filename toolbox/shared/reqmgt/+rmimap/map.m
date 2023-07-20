function result=map(source,varargin)





    if nargout>0
        result=slreq.map(source,varargin{:});
    else
        slreq.map(source,varargin{:});
    end
end
