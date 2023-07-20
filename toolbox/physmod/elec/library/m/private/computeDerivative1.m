function[fx1,wgt1,finiteDiff1]=computeDerivative1(f,Dx1,tol1)





    siz=size(f);
    n1=siz(1);
    finiteDiff1_L=zeros(siz);
    finiteDiff1_U=zeros(siz);
    wgt1_L=zeros(siz);
    wgt1_U=zeros(siz);
    siz1=siz;
    siz1(1)=siz1(1)+1;
    finiteDiff1=zeros(siz1);
    siz3=siz;
    siz3(1)=siz3(1)+3;
    finiteDiff=zeros(siz3);


    finiteDiff(3:n1+1,:)=reshape(bsxfun(@rdivide,diff(f,1,1),Dx1),n1-1,[]);



    finiteDiff(2,:)=2*finiteDiff(3,:)-finiteDiff(4,:);
    finiteDiff(1,:)=2*finiteDiff(2,:)-finiteDiff(3,:);
    finiteDiff(n1+2,:)=2*finiteDiff(n1+1,:)-finiteDiff(n1,:);
    finiteDiff(n1+3,:)=2*finiteDiff(n1+2,:)-finiteDiff(n1+1,:);


    finiteDiff1(:)=finiteDiff(2:n1+2,:);


    wgt1=abs(diff(finiteDiff,1,1));


    finiteDiff1_L(:)=finiteDiff(2:n1+1,:);
    finiteDiff1_U(:)=finiteDiff(3:n1+2,:);


    finiteDiff1_abs_L=abs(finiteDiff1_L)+tol1/2;
    finiteDiff1_abs_U=abs(finiteDiff1_U)+tol1/2;



    wgt1_L(:)=wgt1(1:n1,:);
    wgt1_U(:)=wgt1(3:n1+2,:);
    wgt1_L=wgt1_L+tol1*(finiteDiff1_abs_L./(finiteDiff1_abs_L+finiteDiff1_abs_U));
    wgt1_U=wgt1_U+tol1*(finiteDiff1_abs_U./(finiteDiff1_abs_L+finiteDiff1_abs_U));


    fx1=(wgt1_U.*finiteDiff1_L+wgt1_L.*finiteDiff1_U)./(wgt1_L+wgt1_U);

end