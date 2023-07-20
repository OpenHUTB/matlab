function y=ifftn(varargin)






















    narginchk(1,3);

    xCls=class(varargin{1});
    if(nargin==1)
        X=castFcn(varargin{1});
        y=cast(ifftn(X),xCls);
    elseif(nargin==2)
        X=castFcn(varargin{1});
        SIZ=castFcn(varargin{2});
        y=cast(ifftn(X,SIZ),xCls);
    else
        X=castFcn(varargin{1});
        SIZ=castFcn(varargin{2});
        FLAG=castFcn(varargin{3});
        y=cast(ifftn(X,SIZ,FLAG),xCls);
    end
end

function y=castFcn(x)

    if isa(x,'half')
        y=single(x);
    else
        y=x;
    end
end


