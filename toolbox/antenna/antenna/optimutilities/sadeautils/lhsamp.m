function S=lhsamp(m,n)















    if nargin<1,m=1;end
    if nargin<2,n=m;end

    S=zeros(m,n);
    for i=1:n
        S(:,i)=(rand(1,m)+(randperm(m)-1))'/m;
    end