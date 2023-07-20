function[si]=meshconnvt(t)











    N=max(t,[],"all");
    si=cell(N,1);
    for m=1:N
        temp=(t(:,1)==m)|(t(:,2)==m)|(t(:,3)==m);
        si{m}=find(temp>0);
    end
end

