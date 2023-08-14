function[A2,dAdid2,dAdiq2,dAdX2,B2,X2,T2]=polarAphaseFlux2partialDerivatives_private(A,T,I,B,X,parks_type)%#codegen




    coder.allowpcode('plain');


    n_I=numel(I);
    n_B=numel(B);
    n_X=numel(X);


    I=I(:);
    B=B(:);
    X=X(:);


    T=T(:,:,1:length(X));


    X2=[X(1)-(X(end)-X(end-2));...
    X(1)-(X(end)-X(end-1));...
    X;...
    X(end)+(X(2)-X(1));...
    X(end)+(X(3)-X(1))];


    B2=[B(1)-(B(n_B)-B(n_B-2));...
    B(1)-(B(n_B)-B(n_B-1));...
    B;...
    B(n_B)+(B(2)-B(1));...
    B(n_B)+(B(3)-B(1))];


    At=cat(3,A(:,:,end-2),A(:,:,end-1),A,A(:,:,2),A(:,:,3));
    A2=cat(2,At(:,end-2,:),At(:,end-1,:),At,At(:,2,:),At(:,3,:));


    [dAdI,dAdB2,dAdX2]=gradient(permute(A2,[2,1,3]),I,B2,X2);
    dAdI=permute(dAdI,[2,1,3]);
    dAdB2=permute(dAdB2,[2,1,3]);
    dAdX2=permute(dAdX2,[2,1,3]);


    dAdI=dAdI(:,3:end-2,3:end-2);
    dAdB=dAdB2(:,3:end-2,3:end-2);
    dAdX=dAdX2(:,3:end-2,3:end-2);


    dAdid=zeros(n_I,n_B,n_X);
    dAdiq=zeros(n_I,n_B,n_X);
    for i=1:n_I

        if i==1
            ii=2;
        else
            ii=i;
        end
        for j=1:n_B
            if(parks_type==1)||(parks_type==2)
                id=-I(ii)*sin(B(j));
                iq=I(ii)*cos(B(j));
                dBdid=-iq/(id^2+iq^2);
                dBdiq=id/(id^2+iq^2);
            else
                id=I(ii)*sin(B(j));
                iq=I(ii)*cos(B(j));
                dBdid=iq/(id^2+iq^2);
                dBdiq=-id/(id^2+iq^2);
            end
            dIdid=id/(id^2+iq^2)^(1/2);
            dIdiq=iq/(id^2+iq^2)^(1/2);
            dAdid(i,j,:)=dAdI(ii,j,:)*dIdid+dAdB(ii,j,:)*dBdid;
            dAdiq(i,j,:)=dAdI(ii,j,:)*dIdiq+dAdB(ii,j,:)*dBdiq;
        end
    end


    Tt=cat(3,T(:,:,end-2),T(:,:,end-1),T,T(:,:,2),T(:,:,3));
    T2=cat(2,Tt(:,end-2,:),Tt(:,end-1,:),Tt,Tt(:,2,:),Tt(:,3,:));

    dAdidt=cat(3,dAdid(:,:,end-2),dAdid(:,:,end-1),dAdid,dAdid(:,:,2),dAdid(:,:,3));
    dAdid2=cat(2,dAdidt(:,end-2,:),dAdidt(:,end-1,:),dAdidt,dAdidt(:,2,:),dAdidt(:,3,:));

    dAdiqt=cat(3,dAdiq(:,:,end-2),dAdiq(:,:,end-1),dAdiq,dAdiq(:,:,2),dAdiq(:,:,3));
    dAdiq2=cat(2,dAdiqt(:,end-2,:),dAdiqt(:,end-1,:),dAdiqt,dAdiqt(:,2,:),dAdiqt(:,3,:));

    dAdXt=cat(3,dAdX(:,:,end-2),dAdX(:,:,end-1),dAdX,dAdX(:,:,2),dAdX(:,:,3));
    dAdX2=cat(2,dAdXt(:,end-2,:),dAdXt(:,end-1,:),dAdXt,dAdXt(:,2,:),dAdXt(:,3,:));

end