function y=fft2(varargin)











    narginchk(1,3);

    xCls=class(varargin{1});
    if(nargin==1)
        X=castFcn(varargin{1});
        y=cast(fft2(X),xCls);
    elseif(nargin==2)
        X=castFcn(varargin{1});
        MROWS=castFcn(varargin{2});
        y=cast(fft2(X,MROWS),xCls);
    else
        X=castFcn(varargin{1});
        MROWS=castFcn(varargin{2});
        NCOLS=castFcn(varargin{3});
        y=cast(fft2(X,MROWS,NCOLS),xCls);
    end
end


function y=castFcn(x)

    if isa(x,'half')
        y=single(x);
    else
        y=x;
    end
end


