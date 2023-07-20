function xmf=smfreal(A,B,C,D,E)



















    n=size(A,1);
    nyu=size(D,1);
    xmf=true(n,1);


    Ab=(A~=0);
    Ab(1:n+1:n^2)=true;
    if nargin>4&&~isempty(E)
        Ab=(A~=0)|(E~=0);
    end
    Db=(D~=0);
    Db(1:nyu+1:nyu^2)=true;


    M=[Ab,(B~=0);(C~=0),Db];
    [p,~,r]=dmperm(M);
    isFromA=(p<=n);
    for ct=1:numel(r)-1
        if all(isFromA(r(ct):r(ct+1)-1))

            xmf(p(r(ct):r(ct+1)-1))=false;
        end
    end