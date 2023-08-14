function[D2,Q2,dDdid2,dDdiq2,dDdX2,dQdid2,dQdiq2,dQdX2,B2,X2,T2]=polarDQflux2partialDerivatives_private(D,Q,T,I,B,X,parks_type)%#codegen




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


    Dt=cat(3,D(:,:,end-2),D(:,:,end-1),D,D(:,:,2),D(:,:,3));
    Qt=cat(3,Q(:,:,end-2),Q(:,:,end-1),Q,Q(:,:,2),Q(:,:,3));
    D2=cat(2,Dt(:,end-2,:),Dt(:,end-1,:),Dt,Dt(:,2,:),Dt(:,3,:));
    Q2=cat(2,Qt(:,end-2,:),Qt(:,end-1,:),Qt,Qt(:,2,:),Qt(:,3,:));


    [dDdI,dDdB2,dDdX2]=gradient(permute(D2,[2,1,3]),I,B2,X2);
    [dQdI,dQdB2,dQdX2]=gradient(permute(Q2,[2,1,3]),I,B2,X2);
    dDdI=permute(dDdI,[2,1,3]);
    dDdB2=permute(dDdB2,[2,1,3]);
    dDdX2=permute(dDdX2,[2,1,3]);
    dQdI=permute(dQdI,[2,1,3]);
    dQdB2=permute(dQdB2,[2,1,3]);
    dQdX2=permute(dQdX2,[2,1,3]);


    dDdI=dDdI(:,3:end-2,3:end-2);
    dDdB=dDdB2(:,3:end-2,3:end-2);
    dDdX=dDdX2(:,3:end-2,3:end-2);
    dQdI=dQdI(:,3:end-2,3:end-2);
    dQdB=dQdB2(:,3:end-2,3:end-2);
    dQdX=dQdX2(:,3:end-2,3:end-2);


    dDdid=zeros(n_I,n_B,n_X);
    dDdiq=zeros(n_I,n_B,n_X);
    dQdid=zeros(n_I,n_B,n_X);
    dQdiq=zeros(n_I,n_B,n_X);
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
            dDdid(i,j,:)=dDdI(ii,j,:)*dIdid+dDdB(ii,j,:)*dBdid;
            dDdiq(i,j,:)=dDdI(ii,j,:)*dIdiq+dDdB(ii,j,:)*dBdiq;
            dQdid(i,j,:)=dQdI(ii,j,:)*dIdid+dQdB(ii,j,:)*dBdid;
            dQdiq(i,j,:)=dQdI(ii,j,:)*dIdiq+dQdB(ii,j,:)*dBdiq;
        end
    end


    Tt=cat(3,T(:,:,end-2),T(:,:,end-1),T,T(:,:,2),T(:,:,3));
    T2=cat(2,Tt(:,end-2,:),Tt(:,end-1,:),Tt,Tt(:,2,:),Tt(:,3,:));

    dDdidt=cat(3,dDdid(:,:,end-2),dDdid(:,:,end-1),dDdid,dDdid(:,:,2),dDdid(:,:,3));
    dDdid2=cat(2,dDdidt(:,end-2,:),dDdidt(:,end-1,:),dDdidt,dDdidt(:,2,:),dDdidt(:,3,:));

    dDdiqt=cat(3,dDdiq(:,:,end-2),dDdiq(:,:,end-1),dDdiq,dDdiq(:,:,2),dDdiq(:,:,3));
    dDdiq2=cat(2,dDdiqt(:,end-2,:),dDdiqt(:,end-1,:),dDdiqt,dDdiqt(:,2,:),dDdiqt(:,3,:));

    dQdidt=cat(3,dQdid(:,:,end-2),dQdid(:,:,end-1),dQdid,dQdid(:,:,2),dQdid(:,:,3));
    dQdid2=cat(2,dQdidt(:,end-2,:),dQdidt(:,end-1,:),dQdidt,dQdidt(:,2,:),dQdidt(:,3,:));

    dQdiqt=cat(3,dQdiq(:,:,end-2),dQdiq(:,:,end-1),dQdiq,dQdiq(:,:,2),dQdiq(:,:,3));
    dQdiq2=cat(2,dQdiqt(:,end-2,:),dQdiqt(:,end-1,:),dQdiqt,dQdiqt(:,2,:),dQdiqt(:,3,:));

    dDdXt=cat(3,dDdX(:,:,end-2),dDdX(:,:,end-1),dDdX,dDdX(:,:,2),dDdX(:,:,3));
    dDdX2=cat(2,dDdXt(:,end-2,:),dDdXt(:,end-1,:),dDdXt,dDdXt(:,2,:),dDdXt(:,3,:));

    dQdXt=cat(3,dQdX(:,:,end-2),dQdX(:,:,end-1),dQdX,dQdX(:,:,2),dQdX(:,:,3));
    dQdX2=cat(2,dQdXt(:,end-2,:),dQdXt(:,end-1,:),dQdXt,dQdXt(:,2,:),dQdXt(:,3,:));

end