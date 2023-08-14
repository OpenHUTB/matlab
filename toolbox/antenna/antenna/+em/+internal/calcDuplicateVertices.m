function bbo=calcDuplicateVertices(pts,lmt)
    cnt=size(pts,1);
    nearest_list={};
    u=1;
    kdt=KDTreeSearcher(pts);
    [close_matrx,d_matrx]=knnsearch(kdt,pts((1:cnt),:),'K',20);
    for i=1:cnt
        dflag=1;
        nmbr=10;
        close_m=close_matrx(i,:);
        d_m=d_matrx(i,:);
        if max(d_m)>=lmt
            dflag=0;
            close_verts=close_m(d_m<lmt);
        end
        while dflag
            [nearby,d]=knnsearch(kdt,pts(i,:),'K',20+nmbr);
            if max(d)>=lmt||nmbr>cnt
                dflag=0;
                close_verts=nearby(d<lmt);
            else
                nmbr=nmbr+10;
            end
        end
        if size(close_verts,2)>1
            nearest_list{u,1}=close_verts;%#ok<AGROW> 
            u=u+1;
        end
    end
    bbo=nearest_list;
end