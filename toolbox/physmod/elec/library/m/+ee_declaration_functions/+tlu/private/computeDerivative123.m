function[fx123,finiteDiff123]=computeDerivative123(finiteDiff23,Dx1,wgt1,wgt2,wgt3,tol1,tol2,tol3)%#codegen




    coder.allowpcode('plain');


    siz=size(finiteDiff23);
    siz(2:3)=siz(2:3)-1;
    n1=siz(1);
    n2=siz(2);
    n3=siz(3);
    finiteDiff123_LLL=zeros(siz);
    finiteDiff123_LLU=zeros(siz);
    finiteDiff123_LUL=zeros(siz);
    finiteDiff123_LUU=zeros(siz);
    finiteDiff123_ULL=zeros(siz);
    finiteDiff123_ULU=zeros(siz);
    finiteDiff123_UUL=zeros(siz);
    finiteDiff123_UUU=zeros(siz);
    wgt1_L=zeros(siz);
    wgt1_U=zeros(siz);
    wgt2_L=zeros(siz);
    wgt2_U=zeros(siz);
    wgt3_L=zeros(siz);
    wgt3_U=zeros(siz);
    siz111=siz;
    siz111(1:3)=siz111(1:3)+1;
    finiteDiff123=zeros(siz111);


    finiteDiff123(2:n1,:)=reshape(bsxfun(@rdivide,diff(finiteDiff23,1,1),Dx1),n1-1,[]);



    finiteDiff123(1,:)=2*finiteDiff123(2,:)-finiteDiff123(3,:);
    finiteDiff123(n1+1,:)=2*finiteDiff123(n1,:)-finiteDiff123(n1-1,:);


    finiteDiff123_LLL(:)=finiteDiff123(1:n1,1:n2,1:n3,:);
    finiteDiff123_LLU(:)=finiteDiff123(1:n1,1:n2,2:n3+1,:);
    finiteDiff123_LUL(:)=finiteDiff123(1:n1,2:n2+1,1:n3,:);
    finiteDiff123_LUU(:)=finiteDiff123(1:n1,2:n2+1,2:n3+1,:);
    finiteDiff123_ULL(:)=finiteDiff123(2:n1+1,1:n2,1:n3,:);
    finiteDiff123_ULU(:)=finiteDiff123(2:n1+1,1:n2,2:n3+1,:);
    finiteDiff123_UUL(:)=finiteDiff123(2:n1+1,2:n2+1,1:n3,:);
    finiteDiff123_UUU(:)=finiteDiff123(2:n1+1,2:n2+1,2:n3+1,:);



    wgt1_L(:)=wgt1(1:n1,:,:,:)+tol1/2;
    wgt1_U(:)=wgt1(3:n1+2,:,:,:)+tol1/2;
    wgt2_L(:)=wgt2(:,1:n2,:,:)+tol2/2;
    wgt2_U(:)=wgt2(:,3:n2+2,:,:)+tol2/2;
    wgt3_L(:)=wgt3(:,:,1:n3,:)+tol3/2;
    wgt3_U(:)=wgt3(:,:,3:n3+2,:)+tol3/2;



    fx123=(wgt1_U.*(wgt2_U.*(wgt3_U.*finiteDiff123_LLL...
    +wgt3_L.*finiteDiff123_LLU)...
    +wgt2_L.*(wgt3_U.*finiteDiff123_LUL...
    +wgt3_L.*finiteDiff123_LUU))...
    +wgt1_L.*(wgt2_U.*(wgt3_U.*finiteDiff123_ULL...
    +wgt3_L.*finiteDiff123_ULU)...
    +wgt2_L.*(wgt3_U.*finiteDiff123_UUL...
    +wgt3_L.*finiteDiff123_UUU)))...
    ./((wgt1_L+wgt1_U).*(wgt2_L+wgt2_U).*(wgt3_L+wgt3_U));

end