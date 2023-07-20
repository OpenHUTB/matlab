function[fval]=PVArrayOptimize(x,Voc,Isc,Vm,Im,alpha_isc,beta_voc,Tref_K,Ns,xvec,novar,OptimWeight,Tcell_K)




















































    k=1.3806488e-23;
    k1=8.617332478e-5;
    q=1.6022e-19;
    Sref=1000;
    S=1000;

    if novar>0

        xvec(novar)=x;
        Rsh=xvec(1);
        Rs=xvec(2);
        I0_ref=xvec(3);
        IL_ref=xvec(4);
        nI=xvec(5);
    else

        Rsh=x(1);
        Rs=x(2);
        I0_ref=x(3);
        IL_ref=x(4);
        nI=x(5);
    end

    Rm=Vm/Im;
    Pm=Vm*Im;
    VT_ref=Ns*nI*k*Tref_K/q;


    errIsc=I0_ref*(exp(Rs*Isc/VT_ref)-1)+Isc*(Rs/Rsh+1)-IL_ref;


    errVoc=(IL_ref-I0_ref*(exp(Voc/VT_ref)-1))*Rsh-Voc;


    errVm=(IL_ref-I0_ref*(exp((Vm+Rs*Im)/VT_ref)-1))*Rsh*Rm/(Rsh+Rs+Rm)-Vm;
    errIm=((IL_ref-I0_ref*(exp((Vm+Rs*Im)/VT_ref)-1))*Rsh*Rm/(Rsh+Rs+Rm))/Rm-Im;


    errdPdV=1-(Rs+Rsh)*Pm/Vm^2+Rsh/VT_ref*(1-Rs*Pm/Vm^2)*I0_ref*(exp(Vm/VT_ref*(1+Rs*Pm/Vm^2))-1);


    EgRef=1.121;
    dEgdT=-0.0002677;

    E_g=EgRef*(1+dEgdT*(Tcell_K-Tref_K));
    VT=VT_ref*(Tcell_K/Tref_K);
    IL=S/Sref*(IL_ref+alpha_isc*(Tcell_K-Tref_K));
    I0=I0_ref*((Tcell_K/Tref_K)^3)*exp((EgRef/(k1*Tref_K))-(E_g/(k1*Tcell_K)));

    Voc_Tc=Voc+beta_voc*(Tcell_K-Tref_K);
    errVoc_Tc=(IL-I0*(exp(Voc_Tc/VT)-1))*Rsh-Voc_Tc;

    fval=sum(([errIsc,errVoc,errVm,errIm,errdPdV,errVoc_Tc]./[Isc,Voc,Vm,Im,1,Voc_Tc]).^2.*OptimWeight);