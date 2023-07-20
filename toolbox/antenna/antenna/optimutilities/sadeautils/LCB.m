function y=LCB(y1,MSE,omega)

    sigma=sqrt(MSE);
    y=y1-omega.*sigma;

