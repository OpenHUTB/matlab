function[kappa]=automltirekappa(Re,omega,Vx,VXLOW,kappamax)%#codegen
    coder.allowpcode('plain')








    [~,Vxpabs]=automltirediv0prot(Vx,VXLOW);

    kappa=(Re.*omega-Vx)./Vxpabs;
    kappa(kappa<-kappamax)=-kappamax;
    kappa(kappa>kappamax)=kappamax;
end
