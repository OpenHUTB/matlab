function[P,t]=meshlaplace(P,t,nodes,type,alpha,constraints)




















    if nargin<6
        constraints=[];
    end

    [si]=em.internal.meshprinting.meshconnvt(t);
    Pnew=P;

    switch type
    case 1
        for m=1:length(nodes)
            index=unique(reshape(t(si{nodes(m)},:),1,3*length(si{nodes(m)})));
            index(index==nodes(m))=[];
            Pnew(nodes(m),:)=sum(P(index,:))/length(index);
        end
    case 2
        for m=1:length(nodes)
            index=unique(reshape(t(si{nodes(m)},:),1,3*length(si{nodes(m)})));
            index(index==nodes(m))=[];
            Pnew(nodes(m),:)=alpha*sum(P(index,:))/length(index)+(1-alpha)*P(nodes(m),:);
        end
    case 3
        [ic,r]=em.internal.meshprinting.meshincenters(P,t);
        A=em.internal.meshprinting.meshareas(P,t);
        for m=1:length(nodes)
            tcenters=ic(si{nodes(m)}',:);
            tareas=A(si{nodes(m)}');
            Pnew(nodes(m),:)=sum(tcenters.*repmat(tareas,1,3),1)/sum(tareas);
        end
    case 4
        [cc,R]=em.internal.meshprinting.meshcircumcenters(P,t);
        A=em.internal.meshprinting.meshareas(P,t);
        for m=1:length(nodes)
            ccenters=cc(si{nodes(m)}',:);
            tareas=A(si{nodes(m)}');
            Pnew(nodes(m),:)=sum(ccenters.*repmat(tareas,1,3),1)/sum(tareas);
        end
    end
    P=Pnew;
    if~isempty(constraints)


        warnState=warning('Off','MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId');
        dt=delaunayTriangulation(P(:,1:2),constraints);
        t=dt.ConnectivityList;
        warning(warnState);
    end
end