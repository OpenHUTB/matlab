function[eCellInt]=inter7_full_mesh(P,eCellInt,Epsilon)

    SIZE=max([max(P(:,1))-min(P(:,1)),max(P(:,2))-min(P(:,2))]);
    for m=1:size(P,1)
        Point=P(m,:);
        newnode=m;
        for n=1:size(eCellInt,2)
            e=eCellInt{n};
            eadd=[];
            eremove=[];
            [D,IND]=em.internal.meshprinting.inter2_point_seg(P,e,Point);
            ind=find((IND==-1)&(D<Epsilon));
            for p=1:length(ind)
                edgenum=ind(p);
                if(e(edgenum,1)~=newnode)&(e(edgenum,2)~=newnode)
                    eadd=[eadd;[e(edgenum,1),newnode];[newnode,e(edgenum,2)]];
                    eremove=[eremove;edgenum];
                end
            end
            e(eremove,:)=[];
            e=[e;eadd];
            eCellInt{n}=e;
        end
    end
end
