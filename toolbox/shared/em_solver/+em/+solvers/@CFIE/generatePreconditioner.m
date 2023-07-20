function generatePreconditioner(obj)


    omega=obj.c0*obj.Wavenumber;
    geom=obj.Geom;

    RhoPP=sum(geom.FCRhoP.*geom.FCRhoP,2);
    RhoPM=sum(geom.FCRhoM.*geom.FCRhoP,2);
    RhoMM=sum(geom.FCRhoM.*geom.FCRhoM,2);
    c1=1/(4*pi*1i*omega*obj.epsilon0);
    c2=1i*omega*obj.mu0/(16*pi);
    CPP=(geom.IS(geom.TriP)-1i*obj.Wavenumber).*(+c1+c2*RhoPP);
    CMM=(geom.IS(geom.TriM)-1i*obj.Wavenumber).*(+c1+c2*RhoMM);
    CPM=(exp(-1i*obj.Wavenumber*geom.RWGDistance)./geom.RWGDistance).*(-c1+c2*RhoPM);
    ZD=(CPP+CMM+2*CPM);

    ZM=1*geom.AngleCorrection;

    obj.Preconditioner=(obj.Alpha*ZD+(1-obj.Alpha)*obj.eta0*ZM);
end

