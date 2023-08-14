function y=scalar_interp(x,xVect,yVect,direction)







    I=find(x>=xVect(1:(end-1))&x<=xVect(2:end));

    if isempty(I)
        y=[];
        return;
    end

    if length(I)>1
        if nargin>3&&direction<0
            y=yVect(I(1));
        else
            y=yVect(I(end));
        end
    else
        ind=I+[0,1];
        y=yVect(I)+(x-xVect(I))*diff(yVect(ind))/diff(xVect(ind));
    end