function newy=interpolate(~,x,y,newx,method)







    newy=[];
    if isempty(y)
        return
    end
    x=x(:);
    y=y(:);
    newx=newx(:);


    if nargin<5
        method='linear';
    elseif strcmpi(method,'cubic')
        method='pchip';
    end
    N=numel(newx);


    M=numel(x);
    if(M==0)||(M==1)

        newy(1:N)=y(1);
        newy=newy(:);
    elseif(numel(x)==numel(newx))&&all(x==newx)

        newy=y;
    else

        [x,xindex]=sort(x);
        y=y(xindex);


        newy=interp1(x,y,newx,lower(method),NaN);


        newy(newx<x(1))=y(1);
        newy(newx>x(end))=y(end);
    end
