function[x,y,z]=makeNonNumeric(h,xn,yn,zn)
























    narginchk(3,4)
    if nargin==3
        zn=[];
    end
    if isempty(h)
        h=gca;
    end

    [xr,yr,zr]=matlab.graphics.internal.getRulersForChild(h);
    pax=ancestor(h,'polaraxes');
    if~isempty(pax)

        if strcmp(pax.ThetaAxisUnits,'degrees')
            xn=rad2deg(xn);
        end
    end
    if nargout>0
        x=numericDim(xr,xn);
    end
    if nargout>1
        y=numericDim(yr,yn);
    end
    if nargout>2
        z=numericDim(zr,zn);
    end

    function y=numericDim(ruler,x)
        if isempty(ruler)
            y=x;
        elseif isa(ruler,'matlab.graphics.axis.decorator.NumericRuler')
            y=full(x);
        else
            y=ruler.format(ruler.makeNonNumeric(x));
        end
