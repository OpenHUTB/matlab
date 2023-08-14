function[y,x,r]=idutils_private(varargin)




    a=varargin{1};

    if isa(a,'function_handle')
        a=func2str(a);
    end

    [y,x,r]=msim(a,varargin{2:end});
