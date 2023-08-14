function CurrentCFIE=currentOnPatches(obj)


    geom=obj.Geom;
    CurrentCFIE=zeros(geom.FacesTotal,3);
    ICFIE=obj.IBasis;
    for m=1:geom.EdgesTotal
        TP=geom.TriP(m);
        TM=geom.TriM(m);
        rhoP=geom.FCRhoP(m,:);
        rhoM=geom.FCRhoM(m,:);
        CurrentCFIE(TP,:)=CurrentCFIE(TP,:)+ICFIE(m)*rhoP*geom.EdgeLength(m)/(2*geom.AreaF(TP));
        CurrentCFIE(TM,:)=CurrentCFIE(TM,:)+ICFIE(m)*rhoM*geom.EdgeLength(m)/(2*geom.AreaF(TM));
    end
