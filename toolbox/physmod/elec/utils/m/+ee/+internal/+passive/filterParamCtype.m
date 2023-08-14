function[R,C,L2,C2]=filterParamCtype(QRated,VRated,FRated,connection_option,ftuned,qfactor)%#codegen




    n=ftuned/FRated;
    w0=2*pi*FRated;
    wn=2*pi*ftuned;

    Qbranch=QRated/3;
    if connection_option==ee.enum.filterconnection.delta
        Vbranch=VRated;
    else
        Vbranch=VRated/sqrt(3);
    end

    C=Qbranch/(w0*Vbranch^2);
    C2=C*(n^2-1);
    L2=1/(w0^2*C2);
    R=wn*L2*qfactor;

end
