function[x,y]=snapOpenEndsToLimits(x,y,xLimit,xTol,yLimit,yTol)








    [first,last]=internal.map.findFirstLastNonNan(x);

    if~isempty(first)

        isOpen=~((x(first)==x(last))&(y(first)==y(last)));

        if xTol>0


            x(first(isOpen&(abs(x(first)-xLimit(1))<xTol)))=xLimit(1);
            x(first(isOpen&(abs(x(first)-xLimit(2))<xTol)))=xLimit(2);



            x(last(isOpen&(abs(x(last)-xLimit(1))<xTol)))=xLimit(1);
            x(last(isOpen&(abs(x(last)-xLimit(2))<xTol)))=xLimit(2);
        end

        if nargin>5&&yTol>0


            y(first(isOpen&(abs(y(first)-yLimit(1))<yTol)))=yLimit(1);
            y(first(isOpen&(abs(y(first)-yLimit(2))<yTol)))=yLimit(2);



            y(last(isOpen&(abs(y(last)-yLimit(1))<yTol)))=yLimit(1);
            y(last(isOpen&(abs(y(last)-yLimit(2))<yTol)))=yLimit(2);
        end
    end
end
