function y=fftn(varargin)














    narginchk(1,2);

    xCls=class(varargin{1});
    if(nargin==1)
        X=castFcn(varargin{1});
        y=cast(fftn(X),xCls);
    elseif(nargin==2)
        X=castFcn(varargin{1});
        SIZ=castFcn(varargin{2});
        y=cast(fftn(X,SIZ),xCls);
    end
end

function y=castFcn(x)

    if isa(x,'half')
        y=single(x);
    else
        y=x;
    end
end


