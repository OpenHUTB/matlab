function[YcRe,YcIm,H,V,tau_delay]=transmission_line_distributed_param(R,L,C,G,LEN,freq)





%#codegen
    coder.allowpcode('plain');

    w=2*pi*freq;

    Z=R+1i*w*L;
    Y=G+1i*w*C;
    Gamma=sqrt(Y*Z);

    Yc=Y/Gamma;
    YcRe=real(Yc);
    YcIm=imag(Yc);

    H=abs(exp(-Gamma*LEN));
    V=w/imag(Gamma);
    tau_delay=LEN/V;

end