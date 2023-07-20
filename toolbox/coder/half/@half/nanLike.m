function obj=nanLike(in,varargin)
    obj=half.nan(varargin{:});
    if~isreal(in)
        obj=complex(obj);
    end
end
