function lonlim=unwrapLongitudeLimits(lonlim)


































    zeroWidth=(lonlim(1)==lonlim(2));


    lonlim=lonlim-360*max(0,ceil((lonlim-360)/360));
    lonlim=lonlim+360*max(0,1+floor((-360-lonlim)/360));

    w=lonlim(1);
    e=lonlim(2);






    if e<=w&&w<=0&&~zeroWidth

        e=e+360;
    elseif 0<=e&&e<=w&&~zeroWidth

        w=w-360;
    elseif w<0&&0<e

        if(e-w)>360
            if abs(w)<e
                e=e-360;
            else
                w=w+360;
            end
        end
    elseif e<0&&0<w

        if(w-e)>=360
            w=w-360;
            e=e+360;
        else
            if abs(e)<w
                w=w-360;
            else
                e=e+360;
            end
        end
    elseif w<=e&&e<=-180

        w=w+360;
        e=e+360;
    elseif 180<w&&w<=e

        w=w-360;
        e=e-360;
    end
    lonlim=[w,e];
end
