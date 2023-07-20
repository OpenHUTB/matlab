function[R,L,C]=filterParamHighPass(QRated,VRated,FRated,connection_option,ftuned,qfactor)%#codegen




    Qbranch=QRated/3;
    if connection_option==ee.enum.filterconnection.delta
        Vbranch=VRated;
    else
        Vbranch=VRated/sqrt(3);
    end

    n=ftuned/FRated;
    w0=2*pi*FRated;
    wn=2*pi*ftuned;

    C=(Qbranch/(Vbranch^2*w0))*(n^2-1)/(n^2);
    L=1/(C*wn^2);
    R=wn*L*qfactor;

end
