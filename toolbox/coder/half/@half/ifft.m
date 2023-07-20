function y=ifft(varargin)





















    narginchk(1,4);

    xCls=class(varargin{1});
    if(nargin==1)
        X=castFcn(varargin{1});
        y=cast(ifft(X),xCls);
    elseif(nargin==2)
        X=castFcn(varargin{1});
        N=castFcn(varargin{2});
        y=cast(ifft(X,N),xCls);
    elseif(nargin==3)
        X=castFcn(varargin{1});
        N=castFcn(varargin{2});
        DIM=varargin{3};
        y=cast(ifft(X,N,DIM),xCls);
    else
        X=castFcn(varargin{1});
        N=castFcn(varargin{2});
        DIM=castFcn(varargin{3});
        FLAG=castFcn(varargin{4});
        y=cast(ifft(X,N,DIM,FLAG),xCls);
    end
end

function y=castFcn(x)

    if isa(x,'half')
        y=single(x);
    else
        y=x;
    end
end


