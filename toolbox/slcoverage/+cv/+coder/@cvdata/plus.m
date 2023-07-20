function r=plus(p,q)














    p=cv.coder.cvdata(p);
    q=cv.coder.cvdata(q);


    p.checkDataCompatibility(q);


    ati=cv.internal.cvdata.joinAggregatedTestInfo(p,q);
    ati=cv.internal.cvdata.removeDuplicateTestTraces(ati,[]);


    r=cv.coder.cvdata;
    r.createDerivedData(p,q,'+');



    r.aggregatedTestInfo=ati;
