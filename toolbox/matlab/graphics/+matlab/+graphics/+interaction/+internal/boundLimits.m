function[new_limits]=boundLimits(limits,bounds,keeplimdiff)



    new_limits=limits;
    d=abs(diff(new_limits));


    if new_limits(1)-bounds(1)<0
        new_limits(1)=bounds(1);

        if keeplimdiff
            new_limits(2)=min(bounds(1)+d,bounds(2));
        end
    end

    if bounds(2)-new_limits(2)<0
        new_limits(2)=bounds(2);
        if keeplimdiff
            new_limits(1)=max(bounds(2)-d,bounds(1));


            if new_limits(1)<bounds(1)
                new_limits(1)=bounds(1);
            end
        end
    end

