function obj=onesLike(in,varargin)
    obj=half.ones(varargin{:});
    if~isreal(in)
        obj=complex(obj);
    end
end