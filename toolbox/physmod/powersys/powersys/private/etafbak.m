function[A,B,C,D]=etafbak(A1,B1,C1,D1,a2,b2,c2,no_inp1,no_out1)

















































    [n1,nu]=size(B1);

    [ny,nu]=size(D1);
    [n2,nu2]=size(b2);



    A2=a2;
    B2=zeros(n2,ny);
    B2(:,no_out1)=b2;
    C2=zeros(nu,n2);
    C2(no_inp1,:)=c2;



    A=zeros(n1+n2,n1+n2);
    A(1:n1,1:n1)=A1;
    A(1:n1,n1+1:n1+n2)=B1*C2;
    A(n1+1:n1+n2,1:n1)=B2*C1;
    A(n1+1:n1+n2,n1+1:n1+n2)=A2+B2*D1*C2;

    B=zeros(n1+n2,nu);
    B(1:n1,:)=B1;
    B(n1+1:n1+n2,:)=B2*D1;

    C=zeros(ny,n1+n2);
    C(:,1:n1)=C1;
    C(:,n1+1:n1+n2)=D1*C2;

    D=D1;

