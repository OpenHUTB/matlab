function[fx1234,finiteDiff1234]=computeDerivative1234(finiteDiff234,Dx1,wgt1,wgt2,wgt3,wgt4,tol1,tol2,tol3,tol4)%#codegen




    coder.allowpcode('plain');


    siz=size(finiteDiff234);
    siz(2:4)=siz(2:4)-1;
    n1=siz(1);
    n2=siz(2);
    n3=siz(3);
    n4=siz(4);
    finiteDiff1234_LLLL=zeros(siz);
    finiteDiff1234_LLLU=zeros(siz);
    finiteDiff1234_LLUL=zeros(siz);
    finiteDiff1234_LLUU=zeros(siz);
    finiteDiff1234_LULL=zeros(siz);
    finiteDiff1234_LULU=zeros(siz);
    finiteDiff1234_LUUL=zeros(siz);
    finiteDiff1234_LUUU=zeros(siz);
    finiteDiff1234_ULLL=zeros(siz);
    finiteDiff1234_ULLU=zeros(siz);
    finiteDiff1234_ULUL=zeros(siz);
    finiteDiff1234_ULUU=zeros(siz);
    finiteDiff1234_UULL=zeros(siz);
    finiteDiff1234_UULU=zeros(siz);
    finiteDiff1234_UUUL=zeros(siz);
    finiteDiff1234_UUUU=zeros(siz);
    wgt1_L=zeros(siz);
    wgt1_U=zeros(siz);
    wgt2_L=zeros(siz);
    wgt2_U=zeros(siz);
    wgt3_L=zeros(siz);
    wgt3_U=zeros(siz);
    wgt4_L=zeros(siz);
    wgt4_U=zeros(siz);
    siz1111=siz;
    siz1111(1:4)=siz1111(1:4)+1;
    finiteDiff1234=zeros(siz1111);


    finiteDiff1234(2:n1,:)=reshape(bsxfun(@rdivide,diff(finiteDiff234,1,1),Dx1),n1-1,[]);



    finiteDiff1234(1,:)=2*finiteDiff1234(2,:)-finiteDiff1234(3,:);
    finiteDiff1234(n1+1,:)=2*finiteDiff1234(n1,:)-finiteDiff1234(n1-1,:);


    finiteDiff1234_LLLL(:)=finiteDiff1234(1:n1,1:n2,1:n3,1:n4,:);
    finiteDiff1234_LLLU(:)=finiteDiff1234(1:n1,1:n2,1:n3,2:n4+1,:);
    finiteDiff1234_LLUL(:)=finiteDiff1234(1:n1,1:n2,2:n3+1,1:n4,:);
    finiteDiff1234_LLUU(:)=finiteDiff1234(1:n1,1:n2,2:n3+1,2:n4+1,:);
    finiteDiff1234_LULL(:)=finiteDiff1234(1:n1,2:n2+1,1:n3,1:n4,:);
    finiteDiff1234_LULU(:)=finiteDiff1234(1:n1,2:n2+1,1:n3,2:n4+1,:);
    finiteDiff1234_LUUL(:)=finiteDiff1234(1:n1,2:n2+1,2:n3+1,1:n4,:);
    finiteDiff1234_LUUU(:)=finiteDiff1234(1:n1,2:n2+1,2:n3+1,2:n4+1,:);
    finiteDiff1234_ULLL(:)=finiteDiff1234(2:n1+1,1:n2,1:n3,1:n4,:);
    finiteDiff1234_ULLU(:)=finiteDiff1234(2:n1+1,1:n2,1:n3,2:n4+1,:);
    finiteDiff1234_ULUL(:)=finiteDiff1234(2:n1+1,1:n2,2:n3+1,1:n4,:);
    finiteDiff1234_ULUU(:)=finiteDiff1234(2:n1+1,1:n2,2:n3+1,2:n4+1,:);
    finiteDiff1234_UULL(:)=finiteDiff1234(2:n1+1,2:n2+1,1:n3,1:n4,:);
    finiteDiff1234_UULU(:)=finiteDiff1234(2:n1+1,2:n2+1,1:n3,2:n4+1,:);
    finiteDiff1234_UUUL(:)=finiteDiff1234(2:n1+1,2:n2+1,2:n3+1,1:n4,:);
    finiteDiff1234_UUUU(:)=finiteDiff1234(2:n1+1,2:n2+1,2:n3+1,2:n4+1,:);



    wgt1_L(:)=wgt1(1:n1,:,:,:,:)+tol1/2;
    wgt1_U(:)=wgt1(3:n1+2,:,:,:,:)+tol1/2;
    wgt2_L(:)=wgt2(:,1:n2,:,:,:)+tol2/2;
    wgt2_U(:)=wgt2(:,3:n2+2,:,:,:)+tol2/2;
    wgt3_L(:)=wgt3(:,:,1:n3,:,:)+tol3/2;
    wgt3_U(:)=wgt3(:,:,3:n3+2,:,:)+tol3/2;
    wgt4_L(:)=wgt4(:,:,:,1:n4,:)+tol4/2;
    wgt4_U(:)=wgt4(:,:,:,3:n4+2,:)+tol4/2;



    fx1234=(wgt1_U.*(wgt2_U.*(wgt3_U.*(wgt4_U.*finiteDiff1234_LLLL...
    +wgt4_L.*finiteDiff1234_LLLU)...
    +wgt3_L.*(wgt4_U.*finiteDiff1234_LLUL...
    +wgt4_L.*finiteDiff1234_LLUU))...
    +wgt2_L.*(wgt3_U.*(wgt4_U.*finiteDiff1234_LULL...
    +wgt4_L.*finiteDiff1234_LULU)...
    +wgt3_L.*(wgt4_U.*finiteDiff1234_LUUL...
    +wgt4_L.*finiteDiff1234_LUUU)))...
    +wgt1_L.*(wgt2_U.*(wgt3_U.*(wgt4_U.*finiteDiff1234_ULLL...
    +wgt4_L.*finiteDiff1234_ULLU)...
    +wgt3_L.*(wgt4_U.*finiteDiff1234_ULUL...
    +wgt4_L.*finiteDiff1234_ULUU))...
    +wgt2_L.*(wgt3_U.*(wgt4_U.*finiteDiff1234_UULL...
    +wgt4_L.*finiteDiff1234_UULU)...
    +wgt3_L.*(wgt4_U.*finiteDiff1234_UUUL...
    +wgt4_L.*finiteDiff1234_UUUU))))...
    ./((wgt1_L+wgt1_U).*(wgt2_L+wgt2_U).*(wgt3_L+wgt3_U).*(wgt4_L+wgt4_U));

end