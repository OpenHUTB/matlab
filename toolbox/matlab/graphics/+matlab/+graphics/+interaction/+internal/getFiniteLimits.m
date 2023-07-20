function[finitexlim,finiteylim,finitezlim]=getFiniteLimits(ax)







    ds=ax.ActiveDataSpace;
    finitexlim=ds.XLim;
    finiteylim=ds.YLim;

    if nargout==3
        finitezlim=ds.ZLim;
    end
end