function[P,L0,NR,ND]=privatesbioredsm(N,lflag,tol)




































    [m,n]=size(N');
    if nargin<2
        lflag=0;
    end


    [~,R,P]=qr(full(N'),0);


    maxrank=min(m,n);
    absdiag=abs(diag(R));
    if nargin<3&&~isempty(absdiag)
        tol=max(m,n)*eps(absdiag(1));
    end

    k=0;
    while k<maxrank&&absdiag(k+1)>tol
        k=k+1;
    end




    P=[P(1:k),sort(P(k+1:n))];


    NR=N(P(1:k),:);
    ND=N(P(k+1:n),:);


    L0=ND/NR;







    if lflag
        L0=[eye(k);L0];
    end


