function featureRestore(fvals)



    features=fieldnames(fvals);
    for idx=1:length(features)
        fname=features{idx};
        fval=fvals.(fname);
        slfeature(fname,fval);
    end


    Simulink.slx.refreshPartHandlers;
end
