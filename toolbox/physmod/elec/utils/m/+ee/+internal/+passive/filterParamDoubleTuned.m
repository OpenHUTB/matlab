function[R,L,C,L2,C2]=filterParamDoubleTuned(QRated,VRated,FRated,connection_option,ftuned1,ftuned2,qfactor)%#codegen




    w0=2*pi*FRated;
    w1=2*pi*ftuned1;
    w2=2*pi*ftuned2;
    n1=ftuned1/FRated;
    n2=ftuned2/FRated;

    Qbranch=QRated/3;
    if connection_option==ee.enum.filterconnection.delta
        Vbranch=VRated;
    else
        Vbranch=VRated/sqrt(3);
    end

    Cp1=(Qbranch/2)/(Vbranch^2*w0)*(n1^2-1)/n1^2;
    Cp2=(Qbranch/2)/(Vbranch^2*w0)*(n2^2-1)/n2^2;

    C=Cp1+Cp2;
    L=1/(Cp1*w1^2+Cp2*w2^2);
    ws=1/sqrt(L*C);
    wp=w1*w2/ws;
    L2=(1-(w1/ws)^2)*(1-(w1/wp)^2)/(C*w1^2);
    C2=1/(L2*wp^2);
    R=qfactor*sqrt(w1*w2)*L2;

end
