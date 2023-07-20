function[xn,yn,zn]=makeNumeric(h,x,y,z)























    narginchk(3,4)
    if nargin==3
        z=[];
    end
    if isempty(h)
        h=gca;
    end
    [xr,yr,zr]=matlab.graphics.internal.getRulersForChild(h);

    if nargout>0
        xn=numericDim(xr,x);
    end
    if nargout>1
        yn=numericDim(yr,y);
    end
    if nargout>2
        zn=numericDim(zr,z);
    end

    function y=numericDim(ruler,x)
        if isempty(ruler)||isnumeric(x)
            y=x;
        elseif isa(ruler,'matlab.graphics.axis.decorator.NumericRuler')
            y=double(x);
        else
            y=ruler.makeNumeric(x);
        end
        y=full(y);
