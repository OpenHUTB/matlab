function p=getBoundaryPoints(gd)
    pn1=[];
    pn2=[];
    pn3=[];
    if~isempty(gd)
        y=gd(2,1);
    else
        y=0;
    end
    c=max(size(gd(:,1)));
    if y~=0
        for j=3:y+2
            pn1=[gd(j,1);pn1];
            pn2=[gd(j+y,1);pn2];
            pn3=[0;pn3];
        end
    else
        for j=3:(c/2+1)
            pn1=[gd(j,1);pn1];
            pn2=[gd(j+c/2-1,1);pn2];
            pn3=[0;pn3];
        end
    end
    p=[pn1,pn2,pn3];
end