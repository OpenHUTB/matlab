function y=ifft2(varargin)




















    narginchk(1,4);

    xCls=class(varargin{1});
    if(nargin==1)
        X=castFcn(varargin{1});
        y=cast(ifft2(X),xCls);
    elseif(nargin==2)
        X=castFcn(varargin{1});
        MROWS=castFcn(varargin{2});
        y=cast(ifft2(X,MROWS),xCls);
    elseif(nargin==3)
        X=castFcn(varargin{1});
        MROWS=castFcn(varargin{2});
        NCOLS=castFcn(varargin{3});
        y=cast(ifft2(X,MROWS,NCOLS),xCls);
    else
        X=castFcn(varargin{1});
        MROWS=castFcn(varargin{2});
        NCOLS=castFcn(varargin{3});
        FLAG=castFcn(varargin{4});
        y=cast(ifft2(X,MROWS,NCOLS,FLAG),xCls);
    end
end

function y=castFcn(x)

    if isa(x,'half')
        y=single(x);
    else
        y=x;
    end
end


