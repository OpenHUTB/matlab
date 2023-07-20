function val=fromNormPow(norm,shape,minm,maxm)

    val=minm+(maxm-minm)*(norm.^shape);
end