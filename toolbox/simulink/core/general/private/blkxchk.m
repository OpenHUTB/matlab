function[cros_inf,block_n]=blkxchk(layout,blklocs)



















    cros_inf=[];block_n=[];
    k=0;x=zeros(4,1);
    a=[min(layout);max(layout)];
    if~isempty(blklocs)
        [tmp1,tmp2]=size(blklocs);
        for i=1:tmp1
            b=blklocs(i,:);
            x(1)=(a(1,1)<=b(1)&a(2,1)>=b(1))&~(a(1,2)>b(4)|a(2,2)<b(2));
            x(2)=(a(1,1)<=b(3)&a(2,1)>=b(3))&~(a(1,2)>b(4)|a(2,2)<b(2));
            x(3)=(a(1,2)<=b(2)&a(2,2)>=b(2))&~(a(1,1)>b(3)|a(2,1)<b(1));
            x(4)=(a(1,2)<=b(4)&a(2,2)>=b(4))&~(a(1,1)>b(3)|a(2,1)<b(1));

            x(5)=(a(1,1)>=b(1)&a(2,1)<=b(3))&~(a(1,2)>b(4)|a(2,2)<b(2));
            x(6)=(a(1,2)>=b(2)&a(2,2)<=b(4))&~(a(1,1)>b(3)|a(2,1)<b(1));
            if sum(x)

                k=k+1;
                block_n(k)=i;
                z=find(x==1);
                if length(z)<=1
                    cros_inf(k)=1;
                    if z<=2,cros_inf(k)=3;end;
                else
                    if z(1)>=3
                        cros_inf(k)=2;
                    elseif z(2)<=2
                        cros_inf(k)=4;
                    else
                        cros_inf(k)=6;
                    end;
                end;
            end;
        end;
    end;
