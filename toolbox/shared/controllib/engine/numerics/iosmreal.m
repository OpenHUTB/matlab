function[xkeep,ekeep]=iosmreal(A,B,C,E)














    nu=size(B,2);
    ny=size(C,1);
    nx=size(A,1);
    xkeep=true(nx,ny,nu);
    ekeep=true(nx,ny,nu);
    if nx>0


        if isempty(E)
            AE=spones(A)+speye(nx);
        else
            AE=spones(A)+spones(E);
        end


        for j=1:nu

            [p,q,r,c,~,rr]=dmperm([AE,(B(:,j)~=0);ones(1,nx+1)]);
            if rr(4)==nx+2&&any(q(c(1):c(2)-1)==nx+1)
                ekeep(p(r(2):end),:,j)=false;
                xkeep(q(c(2):end),:,j)=false;
            end
        end


        for i=1:ny
            [p,q,r,c,~,rr]=dmperm([[AE;(C(i,:)~=0)],ones(nx+1,1)]);
            N=numel(r)-1;
            if rr(4)==nx+2&&any(p(r(N):r(N+1)-1)==nx+1)
                ekeep(p(1:r(N)-1),i,:)=false;
                xkeep(q(1:c(N)-1),i,:)=false;
            end
        end
    end