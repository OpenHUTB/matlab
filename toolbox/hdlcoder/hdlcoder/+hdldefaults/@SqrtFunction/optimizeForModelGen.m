function optimize=optimizeForModelGen(this,hN,hC)



    impl=getFunctionImpl(this,hC);
    if(~isempty(impl))
        optimize=impl.optimizeForModelGen(hN,hC);
    else
        optimize=true;
    end

