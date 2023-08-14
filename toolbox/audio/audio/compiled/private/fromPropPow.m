function norm=fromPropPow(val,shape,minm,maxm)

    norm=((val-minm)/(maxm-minm))^(1/shape);
end