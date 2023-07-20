function[A2,dAdid2,dAdiq2,dAdX2,X2,T2]=cartesianAphaseFlux2partialDerivatives_private(A,T,id,iq,X)%#codegen




    coder.allowpcode('plain');


    id=id(:);
    iq=iq(:);
    X=X(:);


    X2=[X(1)-(X(end)-X(end-2));...
    X(1)-(X(end)-X(end-1));...
    X;...
    X(end)+(X(2)-X(1));...
    X(end)+(X(3)-X(1))];


    A2=cat(3,A(:,:,end-2),A(:,:,end-1),A,A(:,:,2),A(:,:,3));


    [dAdid2,dAdiq2,dAdX2]=gradient(permute(A2,[2,1,3]),id,iq,X2);
    dAdid2=permute(dAdid2,[2,1,3]);
    dAdiq2=permute(dAdiq2,[2,1,3]);
    dAdX2=permute(dAdX2,[2,1,3]);


    dAdid=dAdid2(:,:,3:end-2);
    dAdiq=dAdiq2(:,:,3:end-2);
    dAdX=dAdX2(:,:,3:end-2);





    T2=cat(3,T(:,:,end-2),T(:,:,end-1),T,T(:,:,2),T(:,:,3));
    dAdid2=cat(3,dAdid(:,:,end-2),dAdid(:,:,end-1),dAdid,dAdid(:,:,2),dAdid(:,:,3));
    dAdiq2=cat(3,dAdiq(:,:,end-2),dAdiq(:,:,end-1),dAdiq,dAdiq(:,:,2),dAdiq(:,:,3));
    dAdX2=cat(3,dAdX(:,:,end-2),dAdX(:,:,end-1),dAdX,dAdX(:,:,2),dAdX(:,:,3));

end