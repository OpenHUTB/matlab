function x=automlvehdynlongdriverplant(F,G,u,x_o)%#codegen
    coder.allowpcode('plain')






    dt=0.001;


    Ad=expm(F*dt);
    fun=@(t)expm(F*t)*G;
    Bd=(fun(0)+fun(dt))./2*dt;


    x=Ad*[x_o;0]+Bd*u;

end