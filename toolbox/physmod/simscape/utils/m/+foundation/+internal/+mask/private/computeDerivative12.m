

function[fx12,finiteDiff12]=computeDerivative12(finiteDiff2,Dx1,wgt1,wgt2)


    siz=size(finiteDiff2);
    siz(2)=siz(2)-1;
    n1=siz(1);
    n2=siz(2);
    finiteDiff12_LL=zeros(siz);
    finiteDiff12_LU=zeros(siz);
    finiteDiff12_UL=zeros(siz);
    finiteDiff12_UU=zeros(siz);
    wgt1_L=zeros(siz);
    wgt1_U=zeros(siz);
    wgt2_L=zeros(siz);
    wgt2_U=zeros(siz);
    siz11=siz;
    siz11(1:2)=siz11(1:2)+1;
    finiteDiff12=zeros(siz11);



    finiteDiff12(2:n1,:)=reshape(bsxfun(@rdivide,diff(finiteDiff2,1,1),Dx1),n1-1,[]);



    finiteDiff12(1,:)=2*finiteDiff12(2,:)-finiteDiff12(3,:);
    finiteDiff12(n1+1,:)=2*finiteDiff12(n1,:)-finiteDiff12(n1-1,:);


    finiteDiff12_LL(:)=finiteDiff12(1:n1,1:n2,:);
    finiteDiff12_LU(:)=finiteDiff12(1:n1,2:n2+1,:);
    finiteDiff12_UL(:)=finiteDiff12(2:n1+1,1:n2,:);
    finiteDiff12_UU(:)=finiteDiff12(2:n1+1,2:n2+1,:);

    wgt1_L(:)=wgt1(1:n1,:,:);
    wgt1_U(:)=wgt1(3:n1+2,:,:);
    wgt2_L(:)=wgt2(:,1:n2,:);
    wgt2_U(:)=wgt2(:,3:n2+2,:);



    fx12=(wgt1_U.*(wgt2_U.*finiteDiff12_LL+wgt2_L.*finiteDiff12_LU)...
    +wgt1_L.*(wgt2_U.*finiteDiff12_UL+wgt2_L.*finiteDiff12_UU))...
    ./((wgt1_L+wgt1_U).*(wgt2_L+wgt2_U));

    fx12((wgt1_L+wgt1_U).*(wgt2_L+wgt2_U)==0)=0;

end