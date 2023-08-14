function opts=getOptionsForTVOptimization()




    opts=optimset();
    opts.Display='off';
    opts.Algorithm='sqp';
    opts.DiffMinChange=[];
    opts.MaxIter=[];
    opts.TolFun=[];
    opts.MaxFunEvals=[];
    opts.OutputFcn=[];
end



