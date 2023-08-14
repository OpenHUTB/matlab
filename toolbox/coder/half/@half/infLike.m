function obj=infLike(in,varargin)
    obj=half.inf(varargin{:});
    if~isreal(in)
        obj=complex(obj);
    end
end
