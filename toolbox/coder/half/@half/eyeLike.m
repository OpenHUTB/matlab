function obj=eyeLike(in,varargin)
    obj=half.eye(varargin{:});
    if~isreal(in)
        obj=complex(obj);
    end
end