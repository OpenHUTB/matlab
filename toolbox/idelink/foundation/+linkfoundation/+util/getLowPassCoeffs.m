function b=getLowPassCoeffs(N,wb1)










    n=N+1;


    w=linkfoundation.util.hamming(n);



    ff=[0,wb1,wb1,1];
    aa=[1,1,0,0];
    hh=linkfoundation.util.firls(N,ff,aa);



    b=hh.*w';
    b=b/sum(b);

