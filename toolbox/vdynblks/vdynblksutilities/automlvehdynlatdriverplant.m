function x=automlvehdynlatdriverplant(F,g,u,x_o)%#codegen
    coder.allowpcode('plain')






    dt=0.001;


    Ad=expm(F*dt);
    fun=@(t)expm(F*t)*g;
    Bd=(fun(0)+fun(dt))./2*dt;


    x=Ad*x_o+Bd*u;

end