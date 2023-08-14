function r=minus(p,q)



















    p=cv.coder.cvdata(p);
    q=cv.coder.cvdata(q);


    p.checkDataCompatibility(q);


    r=cv.coder.cvdata;
    r=r.createDerivedData(p,q,'-');
