function[D2,Q2,dDdid2,dDdiq2,dDdX2,dQdid2,dQdiq2,dQdX2,X2,T2]=cartesianDQflux2partialDerivatives_private(D,Q,T,id,iq,X)%#codegen 




    coder.allowpcode('plain');


    id=id(:);
    iq=iq(:);
    X=X(:);


    T=T(:,:,1:length(X));


    X2=[X(1)-(X(end)-X(end-2));...
    X(1)-(X(end)-X(end-1));...
    X;...
    X(end)+(X(2)-X(1));...
    X(end)+(X(3)-X(1))];


    D2=cat(3,D(:,:,end-2),D(:,:,end-1),D,D(:,:,2),D(:,:,3));
    Q2=cat(3,Q(:,:,end-2),Q(:,:,end-1),Q,Q(:,:,2),Q(:,:,3));


    [dDdid2,dDdiq2,dDdX2]=gradient(permute(D2,[2,1,3]),id,iq,X2);
    [dQdid2,dQdiq2,dQdX2]=gradient(permute(Q2,[2,1,3]),id,iq,X2);
    dDdid2=permute(dDdid2,[2,1,3]);
    dDdiq2=permute(dDdiq2,[2,1,3]);
    dDdX2=permute(dDdX2,[2,1,3]);
    dQdid2=permute(dQdid2,[2,1,3]);
    dQdiq2=permute(dQdiq2,[2,1,3]);
    dQdX2=permute(dQdX2,[2,1,3]);


    dDdid=dDdid2(:,:,3:end-2);
    dDdiq=dDdiq2(:,:,3:end-2);
    dDdX=dDdX2(:,:,3:end-2);
    dQdid=dQdid2(:,:,3:end-2);
    dQdiq=dQdiq2(:,:,3:end-2);
    dQdX=dQdX2(:,:,3:end-2);


    T2=cat(3,T(:,:,end-2),T(:,:,end-1),T,T(:,:,2),T(:,:,3));
    dDdid2=cat(3,dDdid(:,:,end-2),dDdid(:,:,end-1),dDdid,dDdid(:,:,2),dDdid(:,:,3));
    dDdiq2=cat(3,dDdiq(:,:,end-2),dDdiq(:,:,end-1),dDdiq,dDdiq(:,:,2),dDdiq(:,:,3));
    dQdid2=cat(3,dQdid(:,:,end-2),dQdid(:,:,end-1),dQdid,dQdid(:,:,2),dQdid(:,:,3));
    dQdiq2=cat(3,dQdiq(:,:,end-2),dQdiq(:,:,end-1),dQdiq,dQdiq(:,:,2),dQdiq(:,:,3));
    dDdX2=cat(3,dDdX(:,:,end-2),dDdX(:,:,end-1),dDdX,dDdX(:,:,2),dDdX(:,:,3));
    dQdX2=cat(3,dQdX(:,:,end-2),dQdX(:,:,end-1),dQdX,dQdX(:,:,2),dQdX(:,:,3));

end