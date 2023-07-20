function S=regOrders(Order,numreg,SizeOnlyFlag)























    SizeOnlyFlag=nargin>2&&SizeOnlyFlag;
    x=ones(1,Order);
    x(1)=Order;
    m=1;
    h=1;
    M=[x(1:m),zeros(1,Order-m)];
    while x(1)~=1
        if x(h)==2
            m=m+1;
            x(h)=1;
            h=h-1;
        else
            r=x(h)-1;
            t=m-h+1;
            x(h)=r;
            while t>=r
                h=h+1;
                x(h)=r;
                t=t-r;
            end
            if t==0
                m=h;
            else
                m=h+1;
                if t>1
                    h=h+1;
                    x(h)=t;
                end
            end
        end
        M=cat(1,M,[x(1:m),zeros(1,Order-m)]);
    end
    if numreg>Order
        M=cat(2,M,zeros(size(M,1),numreg-Order));
    end
    S=[];
    n=0;
    for i=1:size(M,1)
        if(sum(M(i,1:numreg))==Order)
            Vi=M(i,1:numreg);
            if SizeOnlyFlag
                n_=getAllUniquePermutations(Vi,true);
                n=n+n_;
            else
                Vi=getAllUniquePermutations(Vi,false);
                S=cat(1,S,Vi);
            end
        end
    end

    if SizeOnlyFlag
        S=n;
    end

end


function Perms=getAllUniquePermutations(vec,SizeOnlyFlag)




    N=numel(vec);
    [UniqVec,~,J]=unique(vec,'stable');
    if isscalar(UniqVec)
        if SizeOnlyFlag
            Perms=1;
        else
            Perms=vec;
        end
        return;
    end
    J=sort(reshape(J,1,N));
    NumRepeat=histcounts(J,1:J(end)+1);


    CP=cumprod([1,1,2:N]);
    NumUniquePerms=floor(CP(N+1)/prod(CP(NumRepeat+1)));
    if nargin>1&&SizeOnlyFlag
        Perms=NumUniquePerms;
        return;
    end

    Perms=repmat(J,NumUniquePerms,1);
    P1=Perms(1,:);
    for k=2:NumUniquePerms

        i=find(P1(2:end)>P1(1:end-1),1,'last');

        j=find(P1(i)<P1,1,'last');
        P1([i,j])=P1([j,i]);
        P1(i+1:N)=P1(N:-1:i+1);
        Perms(k,:)=P1;
    end
    Perms=UniqVec(Perms);
end
