function[V_PV,I_PV]=PVArrayParam(S,Tcell_C,IL_ref,I0_ref,nI_ref,Rs_ref,Rsh_ref,Voc,Vm,Im,alpha_isc,beta_voc,Ns)























    Tref_K=25+273.15;
    Tcell_K=Tcell_C+273.15;
    Sref=1000;
    k=1.3806e-23;
    k1=8.617332478e-5;
    q=1.6022e-19;
    EgRef=1.121;
    dEgdT=-0.0002677;
    VT_ref=Ns*nI_ref*k*Tref_K/q;
    E_g=EgRef*(1+dEgdT*(Tcell_K-Tref_K));
    VT=VT_ref*(Tcell_K/Tref_K);
    IL=S/Sref*(IL_ref+alpha_isc*(Tcell_K-Tref_K));
    I0=I0_ref*((Tcell_K/Tref_K)^3)*exp((EgRef/(k1*Tref_K))-(E_g/(k1*Tcell_K)));
    Voc_T=Voc+beta_voc*(Tcell_K-Tref_K);

















    Vd=[0:Voc/500:(0.99*Vm+Rs_ref*Im),(Vm:Voc_T/1000:1.02*Voc_T)+Rs_ref*Im];
    Id=I0*(exp(Vd/VT)-1);




    Rsh=Rsh_ref*Sref/S;
    Rs=Rs_ref;
    I=IL-Id-Vd/Rsh;
    V=Vd-Rs*I;
    n=find(I>=0&V>=0);
    I_PV=I(n);
    V_PV=V(n);