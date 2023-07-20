function[Rbar,Mbar,Ibar,Xbar,Wbar,HPbar]=vehdyncginrt1axl(m,z1m,z2m,z3m,z4m,z5m,z6m,z7m,z1R,z2R,z3R,z4R,z5R,z6R,Iveh,z1I,z2I,z3I,z4I,z5I,z6I,z7I,z7R,a,h,w,d)%#codegen
    coder.allowpcode('plain')


    z0R=[0,0,0];
    Rload=repmat([a,-d,h],[7,1])+[z1R;z2R;z3R;z4R;z5R;z6R;z7R].*repmat([-1,1,-1],[7,1]);
    R=[z0R;Rload];
    M=[m;z1m;z2m;z3m;z4m;z5m;z6m;z7m];
    Imat=cat(3,Iveh,z1I,z2I,z3I,z4I,z5I,z6I,z7I);
    [Rbar,Mbar,Ibar]=vehdyncginert(R,M,Imat);
    Xbar=[a+Rbar(1),h-Rbar(3)];
    w=w./2;
    Wbar=[w(1)+Rbar(2),w(1)-Rbar(2)];
    HPbar=[-Xbar(1),-Xbar(1);
    -Wbar(1),Wbar(2);
    Xbar(2),Xbar(2)];
end