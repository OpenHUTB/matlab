function expandIncidentField(obj)




    k=obj.Wavenumber*obj.WaveDirection;
    Pol=obj.WavePolarization;
    Polh=cross(k,obj.WavePolarization)/obj.Wavenumber;
    geom=obj.Geom;



    pol=repmat(Pol,geom.FacesTotal,1);
    K=repmat(k,geom.FacesTotal,1);
    kr=dot(K,geom.CenterF,2);
    Einc=pol.*repmat(exp(-1i*kr),1,3);


    V=zeros(geom.EdgesTotal,1);
    for m=1:geom.EdgesTotal
        TP=geom.TriP(m);
        TM=geom.TriM(m);
        ScalarPlus=sum(Einc(TP,:).*geom.FCRhoP(m,:));
        ScalarMinus=sum(Einc(TM,:).*geom.FCRhoM(m,:));
        V(m)=(ScalarPlus/2+ScalarMinus/2)/geom.EdgeLength(m);
    end


    pol=repmat(Polh,geom.EdgesTotal,1);
    K=repmat(k,geom.EdgesTotal,1);
    kr=dot(K,geom.RWGCenter,2);
    Hinc=1/obj.eta0*pol.*repmat(exp(-1i*kr),1,3);


    IMFIE=zeros(geom.EdgesTotal,1);
    for m=1:geom.EdgesTotal
        t1=geom.TriP(m);
        t2=geom.TriM(m);
        normaledge=geom.NormalF(t1,:)+geom.NormalF(t2,:);
        IMFIE(m)=2*sum(Hinc(m,:).*geom.RWGevector(m,:));
    end


    obj.V_efie=V;
    obj.I_mfie=IMFIE;
end
