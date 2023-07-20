function[Par1,Par2,Par3]=...
    simrfV2_pot_cnsts(CurveType_val,ron_val,roff_val,percent)


    opts=optimset('MaxIter',1e4,'MaxFunEvals',1e4,...
    'TolFun',1e-8,'TolX',1e-8);
    switch CurveType_val
    case 1
        Par1={0,'Ohm'};
        Par2={0,'1'};
        Par3={0,'Ohm'};
    case 2
        xdata=[0,.5,1];
        ydata=[ron_val,...
        roff_val*(percent/100)+(1-(percent/100))*ron_val,roff_val];
        init_guess=[1,3,-1];
        [cnsts,fval,exitflag,output]=...
        fminsearch(@(x)expfun2(x,xdata,ydata),init_guess,opts);
        [cnsts,fval,exitflag,output]=...
        fminsearch(@(x)expfun2(x,xdata,ydata),cnsts,opts);
        Par1={cnsts(1),'Ohm'};
        Par2={cnsts(2),'1'};
        Par3={cnsts(3),'Ohm'};
    case 3
        xdata=[0,.5,1];
        ydata=[ron_val,...
        roff_val*(percent/100)+(1-(percent/100))*ron_val,roff_val];
        init_guess=[1,3,-1];
        [cnsts,fval,exitflag,output]=...
        fminsearch(@(x)expfun3(x,xdata,ydata,ron_val),init_guess,opts);
        [cnsts,fval,exitflag,output]=...
        fminsearch(@(x)expfun3(x,xdata,ydata,ron_val),cnsts,opts);
        Par1={cnsts(1),'Ohm'};
        Par2={cnsts(2),'1'};
        Par3={cnsts(3),'Ohm'};
    end
end





function[sse,FittedCurve]=expfun2(pars,xdata,ydata)
    FittedCurve=pars(1)*exp(pars(2)*xdata)+pars(3);
    ErrorVector=FittedCurve-ydata;
    sse=sum(ErrorVector.^2);
end

function[sse,FittedCurve]=expfun3(pars,xdata,ydata,Ron)
    FittedCurve=pars(1)*log((1+xdata*pars(2)))+pars(3)*xdata+Ron;
    ErrorVector=FittedCurve-ydata;
    if pars(1)<=0||pars(2)<0
        sse=1e30;
    else
        sse=sum(ErrorVector.^2);
    end
end