function[tr,idxfeedint]=createHole(trobj,triindx,fw,rotatedpoints,pt)


    tripoints=rotatedpoints(trobj.ConnectivityList(triindx,:),:);
    feedpoints=[fw/2,0,0;0,-fw/2,0;-fw/2,0,0;0,fw/2,0]*1.5;
    feedpointsorig=feedpoints;
    feedtri=[1,2,3;3,4,1];
    in=inpolygon(feedpoints(:,1),feedpoints(:,2),tripoints(:,1),tripoints(:,2));

    warnMsgFlag=0;
    if~all(in)

        flag=1;
        while flag

            tri=trobj.neighbors(reshape(triindx,numel(triindx),1));
            [tri,~]=setdiff(transpose(tri(:)),triindx);
            tri=tri(~isnan(tri));
            try

            catch ME
                disp('error');
            end
            if isempty(tri)
                break;
            end



            validIdx=em.internal.stl.checkTriangle(trobj,tri);tri=tri(validIdx);
            idxfeedtri=zeros(numel(tri),1);
            idxtri=zeros(numel(tri),1);
            for i=1:numel(tri)


                feedin=inpolygon(feedpoints(:,1),feedpoints(:,2),rotatedpoints(trobj.ConnectivityList(tri(i),:),1),rotatedpoints(trobj.ConnectivityList(tri(i),:),2));
                idxfeedtri(i)=any(feedin);


                triin=inpolygon(rotatedpoints(trobj.ConnectivityList(tri(i),:),1),rotatedpoints(trobj.ConnectivityList(tri(i),:),2),feedpoints(:,1),feedpoints(:,2));
                idxtri(i)=any(triin);
            end
            idxtri=idxtri|idxfeedtri;
            feededges=[1,2;2,3;3,4;4,1];
            tmptri=tri(~idxtri);


            idxind=zeros(numel(tmptri),1);
            for i=1:numel(tmptri)
                triedges=trobj.ConnectivityList(tmptri(i),:);
                triedges=[triedges',circshift(triedges',-1)];
                for k=1:3
                    for j=1:4
                        [~,~,ind]=em.internal.meshprinting.inter1_seg_seg(...
                        rotatedpoints(triedges(k,:),1),rotatedpoints(triedges(k,:),2),...
                        feedpoints(feededges(j,:),1),feedpoints(feededges(j,:),2));
                        if ind==1
                            break;
                        end
                    end
                    if ind==1
                        break;
                    end
                end
                idxind(i)=ind;
            end
            if~isempty(tmptri)


                idxtri(~idxtri)=idxind;
            end
            tri=tri(logical(idxtri));
            idxtri=[];idxfeedtri=[];idxind=[];
            tri=[tri,triindx];
            if numel(triindx)==numel(tri)&&all(triindx==tri)


                break;
            end
            triindx=tri;
        end
        idxptsfeed=zeros(4,1);


        for i=1:4
            in=em.internal.stl.inTri(rotatedpoints,trobj.ConnectivityList(triindx,:),[feedpoints(i,1),feedpoints(i,2),pt(3)]);
            idxptsfeed(i)=in;
        end
        in=idxptsfeed;
    end

    if~all(in)

        idxfeedint=-1;
        tr=triindx;
        return;
    end


    feedpoints=feedpoints*(2/3);
    trimat=trobj.ConnectivityList(triindx,:);
    ptlist=unique(trimat);
    trimat=trimat(:);
    for i=1:numel(ptlist)
        trimat(trimat==ptlist(i))=i;
    end
    trimat=reshape(trimat,size(triindx,2),3);
    tripoints=rotatedpoints(ptlist,:);


    isIntersectingBound=em.internal.stl.checkBoundaryIntersectionWithSquare(feedpoints,feedtri,[tripoints(:,1:2),zeros(size(tripoints,1),1)],trimat);

    if isIntersectingBound

        idxfeedint=-1;
        tr=triindx;
        return;
    end






    [p,t]=em.internal.stl.imprintMesh(feedpoints,feedtri,[tripoints(:,1:2),zeros(size(tripoints,1),1)],trimat);
    M.P=p;
    M.t=t;
    cl=trobj.ConnectivityList;
    cl(triindx,:)=[];
    idxptlist=[];

    val=size(M.P,1)+size(rotatedpoints,1);
    changedidx=zeros(size(M.P,1),1);
    tmp=t;

    t=t(:);
    for i=1:size(tripoints,1)

        idx=M.P(:,1)==tripoints(i,1)&M.P(:,2)==tripoints(i,2);
        if~any(idx)
            continue;
        else

            idxptlist=[idxptlist;find(idx),ptlist(i)];
            changedidx=idx|changedidx;
        end
    end

    vect=find(~(changedidx));
    for i=1:numel(vect)
        t(t==vect(i))=i+val;
    end
    vectn=find((changedidx));
    for i=1:numel(vectn)
        t(t==vectn(i))=vectn(i)+val+max(vect);
    end
    for i=1:size(idxptlist)
        t(t==idxptlist(i,1)+val+max(vect))=idxptlist(i,2);
    end
    M.P(changedidx,:)=[];

    for i=1:numel(vect)
        t(t==i+val)=i+size(rotatedpoints,1);
    end
    t=reshape(t,numel(t)/3,3);
    val=size(rotatedpoints,1);
    zval=pt(3);
    M.P(:,3)=zval;
    idxfeedint=size(rotatedpoints,1);
    rotatedpoints=[rotatedpoints;M.P];
    cl=[cl;t];
    tr=triangulation(cl,rotatedpoints);
end










