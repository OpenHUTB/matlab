function[aout,bout,cout,dout]=psb_c2d(a,b,c,d,T,SolverType)








    switch SolverType
    case{'Tustin','Tustin/Backward Euler (TBE)'}
        invexp=inv(eye(size(a,1))-(T/2)*a);


        aout=invexp*(eye(size(a,1))+(T/2)*a);
        bout=invexp*b;
        cout=c*invexp*T;
        dout=c*invexp*b*(T/2)+d;

    case 'Backward Euler'
        invexp=inv(eye(size(a,1))-T*a);


        aout=invexp;
        bout=invexp*b;
        cout=c*invexp*T;
        dout=c*invexp*b*T+d;
    end