function[p,t]=reMat2(p_in,t_in)
    [r1,c1]=size(p_in);
    [r2,c2]=size(t_in);
    if r2~=4
        t_in=t_in';
    end
    if r1~=3
        p_in=p_in';
    end
    [r2,c2]=size(t_in);
    h=1;
    u(1:c2)=0;
    for i=1:c2
        for j=1:r2
            k=t_in(j,i);
            x=ismember(u,k);
            if(x==0)
                p(:,h)=p_in(:,k);
                u(h)=k;

                h=h+1;
            end
            t_in(j,i)=find(u==k);
        end
    end
    t=t_in;
end