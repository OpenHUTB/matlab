function y=fft(varargin)


























    narginchk(1,3);

    xCls=class(varargin{1});
    if(nargin==1)
        X=castFcn(varargin{1});
        y=cast(fft(X),xCls);
    elseif(nargin==2)
        X=castFcn(varargin{1});
        N=castFcn(varargin{2});
        y=cast(fft(X,N),xCls);
    else
        X=castFcn(varargin{1});
        N=castFcn(varargin{2});
        DIM=castFcn(varargin{3});
        y=cast(fft(X,N,DIM),xCls);
    end
end

function y=castFcn(x)

    if isa(x,'half')
        y=single(x);
    else
        y=x;
    end
end


