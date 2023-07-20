function[H,g,g0,A,b,Aeq,beq,d]=mv_optim_max_sharpe_transform(obj)

































    [A,b,f0,f,H,g,d]=mv_optim_transform(obj);
    g0=d'*H*d;


    if~isempty(obj.RiskFreeRate)

        f0=f0-obj.RiskFreeRate;
    end




    Aeq=[f;f0]';
    beq=1;


    A=[A,-b];
    b=zeros(length(b),1);
    d=[d;0];

end
