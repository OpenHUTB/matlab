function norm=fromPropInt(val,minm,maxm)

    d=1/(maxm-minm);
    int_range=minm:maxm;
    range=0:d:1;
    norm=range(int_range==val);

end
