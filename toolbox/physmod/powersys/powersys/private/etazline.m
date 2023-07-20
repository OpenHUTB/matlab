function[z_ser,y_sh]=etazline(long,r,x,b)






















    z=r+j*x;
    y=j*b;
    gamal=(y*z)^0.5*long;
    zc=(z/y)^0.5;
    z_ser=sinh(gamal)*zc;
    y_sh=tanh(gamal/2.0)/zc;
