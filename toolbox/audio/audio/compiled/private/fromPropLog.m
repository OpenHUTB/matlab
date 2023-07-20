function norm=fromPropLog(val,minm,maxm)

    norm=(log(val)-log(minm))/(log(maxm)-log(minm));
end