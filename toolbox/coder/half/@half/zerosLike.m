function obj=zerosLike(in,varargin)
    obj=half.zeros(varargin{:});
    if~isreal(in)
        obj=complex(obj);
    end
end