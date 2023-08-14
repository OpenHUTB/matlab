function[xhat,yhat]=automlvehdynlatlongdriverplant(F,G,a_star,b_star,x_o,u)%#codegen
    coder.allowpcode('plain')


    dt=0.001;


    Ad=expm(F*dt);
    fun=@(t)expm(F*t)*G;
    Bd=(fun(0)+fun(dt))./2*dt;
    xhat=Ad*x_o+Bd*u;

    y1=b_star(1:2)*xhat(1:2)+u(1)*a_star(1);
    y2=b_star(3:6)*xhat(3:6)+u(2)*a_star(2);
    yhat=[y1;y2];
end