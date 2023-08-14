function hNewC=elaborate(this,hN,blockComp)





    impl=getFunctionImpl(this,blockComp);
    hNewC=impl.elaborate(hN,blockComp);
