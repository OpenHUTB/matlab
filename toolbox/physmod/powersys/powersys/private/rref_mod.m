function[A,jb,b]=rref_mod(A,tol)


















    [m,n]=size(A);


    b=1:m;






    if(nargin<2),tol=max(m,n)*eps(class(A))*norm(A,'inf');end


    i=1;
    j=1;
    jb=[];
    xb=[];
    while(i<=m)&&(j<=n)

        [p,k]=max(abs(A(i:m,j)));k=k+i-1;
        if(p<=tol)

            A(i:m,j)=zeros(m-i+1,1);
            j=j+1;
        else

            jb=[jb,j];



            b([i,k])=b([k,i]);

            A([i,k],j:n)=A([k,i],j:n);

            A(i,j:n)=A(i,j:n)/A(i,j);

            for k=[1:i-1,i+1:m]
                A(k,j:n)=A(k,j:n)-A(k,j)*A(i,j:n);
            end
            i=i+1;
            j=j+1;
        end
    end







