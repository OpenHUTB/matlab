function[p_index,p_feed,h_feed]=getFixedVertices2(p,gd,Hmax,fw)
    [rG,cG]=size(gd);
    pn1=[];
    pn2=[];
    pn1_f=[];
    pn2_f=[];
    h_feed=[];
    for i=1:cG
        y=gd(2,i);
        if y~=0
            for j=3:y+2
                if cG~=1
                    pn1=[gd(j,i);pn1];
                    pn2=[gd(j+y,i);pn2];
                    if(i~=1&&i~=cG)||(i~=1&&max(gd(2,1)~=gd(2,end)))
                        pn1_f=[gd(j,i);pn1_f];
                        pn2_f=[gd(j+y,i);pn2_f];
                        h_feed=[fw,h_feed];
                    else
                        h_feed=[Hmax,h_feed];
                    end
                else
                    pn1=[gd(j,i);pn1];
                    pn2=[gd(j+y,i);pn2];
                    pn1_f=[gd(j,i);pn1_f];
                    pn2_f=[gd(j+y,i);pn2_f];
                end
            end
        else
            for j=3:(rG/2+1)
                if i~=1&&i~=cG
                    pn1=[gd(j,i);pn1];
                    pn2=[gd(j+rG/2-1,i);pn2];
                    pn1_f=[gd(j,i);pn1_f];
                    pn2_f=[gd(j+y,i);pn2_f];
                end
            end
        end
    end














    index=[];
    index_f=[];
    for i=1:max(size(pn1))
        temp=find(abs(p(1,:)-pn1(i))<1e-7...
        &abs(p(2,:)-pn2(i))<1e-7);
        index=[index,temp];
    end
    for j=1:max(size(pn1_f))
        temp_f=find(abs(p(1,:)-pn1_f(j))<1e-7...
        &abs(p(2,:)-pn2_f(j))<1e-7);
        index_f=[index_f,temp_f];
    end
    p_index=unique(index);
    p_feed=unique(index_f);

end