function[p,t]=imprintMesh(p1,t1,p2,t2)



    tr1=triangulation(t1,p1);
    tr2=triangulation(t2,p2);
    fe1=freeBoundary(tr1);
    fe2=freeBoundary(tr2);
    b1=em.internal.stl.lineupBoundary(fe1);
    b2=em.internal.stl.lineupBoundary(fe2);
    nearestidx=zeros(numel(b2,1));
    d1=(p2(b2,:)-p1(1,:));d1=sum(d1.^2,2);
    d2=(p2(b2,:)-p1(2,:));d2=sum(d2.^2,2);
    d3=(p2(b2,:)-p1(3,:));d3=sum(d3.^2,2);
    d4=(p2(b2,:)-p1(4,:));d4=sum(d4.^2,2);
    d=[d1,d2,d3,d4];
    [~,nid]=min(d');
    n=numel(b1);
    p=[p1;p2];
    t=[];
    b2=[b2;b2(1)];
    nid=[nid,nid(1);];
    for i=1:numel(b2)-1
        if nid(i)==nid(i+1)
            t=[t;[b2(i)+4,b2(i+1)+4,nid(i)]];
        else
            if abs(nid(i+1)-nid(i))==1||abs(nid(i+1)-nid(i))==3

                tmptri=[b2(i)+4,b2(i+1)+4,nid(i);b2(i+1)+4,nid(i),nid(i+1)];
                isIntersecting=[0,0];
                for k=1:2
                    isIntersecting(k)=em.internal.stl.checkBoundaryIntersectionWithSquare(p1,t1,p,tmptri(k,:),1);
                    if isIntersecting(k)
                        break;
                    end
                end
                if any(isIntersecting)
                    tmptri=[b2(i)+4,b2(i+1)+4,nid(i+1);b2(i)+4,nid(i),nid(i+1)];
                end
                t=[t;tmptri];
            elseif abs(nid(i+1)-nid(i))==2


                remidx=setdiff([1,2,3,4],[nid(i+1),nid(i)]);
                dd1=p2(b2(i:i+1),:)-p1(remidx(1),:);dd1=sum(dd1.^2,2);dd1=sum(dd1);
                dd2=p2(b2(i:i+1),:)-p1(remidx(2),:);dd2=sum(dd2.^2,2);dd2=sum(dd2);
                [~,remptidx]=min([dd1;dd2]);

                tmptri=[[b2(i)+4,remidx(remptidx),nid(i)];[b2(i+1)+4,nid(i+1),remidx(remptidx)];[b2(i)+4,b2(i+1)+4,remidx(remptidx)]];
                isIntersecting=[0,0,0];
                for k=1:3
                    isIntersecting(k)=em.internal.stl.checkBoundaryIntersectionWithSquare(p1,t1,p,tmptri(k,:),1);
                    if isIntersecting(k)
                        break;
                    end
                end
                if all(isIntersecting==[1,0,0])


                    tmptri=[[b2(i+1)+4,remidx(remptidx),nid(i)];[b2(i+1)+4,nid(i+1),remidx(remptidx)];[b2(i)+4,b2(i+1)+4,nid(i)]];
                elseif all(isIntersecting==[0,1,0])

                    tmptri=[[b2(i)+4,remidx(remptidx),nid(i)];[b2(i)+4,nid(i+1),remidx(remptidx)];[b2(i)+4,b2(i+1)+4,nid(i+1)]];
                end
                t=[t;tmptri];
            end
        end
    end
end