function hNewC=preElab(this,hN,hC)



    impl=getFunctionImpl(this,hC);
    hNewC=impl.preElab(hN,hC);

end
