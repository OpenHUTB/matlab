function updateModelForProducts(h)


















































































    for i=1:length(h.RegisteredProductFH)
        fH=h.RegisteredProductFH{i};
        fH(h);
    end


    if h.CheckFlags.BlockReplace
        for i=1:length(h.ProductFH)
            fH=h.ProductFH{i};
            fH(h);
        end
    end


    doCompileChecks(h);
