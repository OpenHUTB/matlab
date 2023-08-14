function ValidateObjectForBehavioral(obj,freq)





    try
        vp=3e8;
        fmeshing=freq(1);
        lambdameshing=vp/fmeshing;
        [~]=mesh(obj,'MaxEdgeLength',10*lambdameshing);
    catch ME
        throw(ME)
    end
end