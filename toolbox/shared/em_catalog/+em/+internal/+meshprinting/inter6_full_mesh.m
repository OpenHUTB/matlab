function[P,t,edges,pspecial,especial,feed_new]=inter6_full_mesh(PCell,gd,eCellInt,P,MaxEdgeLength,...
    MinContourLength,GrowthRate,iter,feed,...
    BaseMeshChoice,MinFeatureSize,Epsilon,...
    RefineContours,edgeStatus)










    edges=[];
    pspecial=[];
    especial=[];

    if any(edgeStatus)
        edgeStatus='unsplit';
    end


    edges=vertcat(eCellInt{:});
    edges=sort(edges,2);
    [edges,ia,ic]=unique(edges,'rows','stable');


    L=max(PCell{1}(:,1))-min(PCell{1}(:,1));
    W=max(PCell{1}(:,2))-min(PCell{1}(:,2));
    feed_new=feed;
    pspecial=[];
    especial=[];



    while 1
        temp=P(edges(:,1),:)-P(edges(:,2),:);
        edgelength=sqrt(dot(temp,temp,2));

        index=find(edgelength>MinContourLength);

        if~isempty(feed_new)







            [special_edges,feed_index]=em.internal.meshprinting.inter10a_full_mesh(P,edges,feed_new,Epsilon);
            temp=[];
            for m=1:length(special_edges)
                temp=[temp;find(index==special_edges(m))];
            end
            if strcmpi(edgeStatus,'unsplit')
                index(temp')=[];
            end

        end
        eadd=[];
        eremove=[];
        feed_newtemp={};
        if~isempty(index)
            for m=1:length(index)
                n=index(m);
                Pmiddle=0.5*(P(edges(n,1),:)+P(edges(n,2),:));
                P=[P;Pmiddle];
                newnode=size(P,1);


                eadd=[eadd;[edges(n,1),newnode];[newnode,edges(n,2)]];
                if ismember(n,special_edges)
                    newpts=0.5*(P(([edges(n,1),newnode]),:)+P(([newnode,edges(n,2)]),:));
                    indx_fv=special_edges==n;
                    feed_newtemp{indx_fv}=newpts;
                end
                eremove=[eremove;n];
            end
            edges(eremove,:)=[];
            edges=[edges;eadd];
            if~strcmpi(edgeStatus,'unsplit')



                feed_newtemp=cell2mat(feed_newtemp');
                if~isempty(feed_newtemp)
                    feed_new=feed_newtemp;
                end
                [especial,~]=em.internal.meshprinting.inter10a_full_mesh(P,edges,feed_new,Epsilon);

                pspecial=P(edges(especial,:),:);
            end
        else
            break;
        end
    end
    bypass=1;
    if bypass


        [P,edges]=em.internal.meshprinting.collapseNearbyContours(P,edges);


        warnState1=warning('Off','MATLAB:delaunayTriangulation:DupConsWarnId');
        warnState2=warning('Off','MATLAB:delaunayTriangulation:DupPtsConsUpdatedWarnId');
        warnState3=warning('Off','MATLAB:delaunayTriangulation:ConsSplitPtWarnId');
        dt=delaunayTriangulation(P,edges);
        P=dt.Points;
        t=dt.ConnectivityList;
        edges=dt.Constraints;
        warning(warnState1);
        warning(warnState2);
        warning(warnState3);
        return;
    end




    switch BaseMeshChoice
    case 'Structured'


        Tri=2*round(L*W/MaxEdgeLength^2);
        Pinner=em.internal.meshprinting.inter5_inner_plate_nodes(L,W,Tri);





    case 'Unstructured'
        Tri=MaxEdgeLength;
        gr=GrowthRate;
        [dl,~]=decsg_atx(gd);
        [Pinner,Einner,Tinner]=initmesh_atx(dl,'Hmax',Tri,'Hgrad',gr,'MesherVersion','R2013a','Init','on');
        Pinner=Pinner';
        Tinner=Tinner';















    end


    out_close=[];
    for m=1:size(Pinner,1)
        temp=P-repmat(Pinner(m,:),size(P,1),1);
        temp=sqrt(dot(temp,temp,2));
        if any(temp<Epsilon)
            out_close=[out_close,m];%#ok<AGROW>
        end
    end
    Pinner(out_close,:)=[];


    out_inner=[];
    for m=1:size(Pinner,1)
        [D,IND]=em.internal.meshprinting.inter2_point_seg(P,edges,Pinner(m,:));
        index=find(D<Epsilon&IND==-1);
        if~isempty(index)
            out_inner=[out_inner,m];%#ok<AGROW>
        end
    end
    Pinner(out_inner,:)=[];



    Pc=P;

    I=size(P,1);
    P=[P;Pinner];
    if strcmpi(BaseMeshChoice,'Unstructured')

        P=unique(P,'rows','stable');
    end


    eCellIntN=em.internal.meshprinting.inter7_full_mesh(P,eCellInt,Epsilon);


    edges=[];
    for m=1:size(eCellIntN,2)
        edges=[edges;eCellIntN{m}];%#ok<AGROW>
    end
    for m=1:size(edges,1)
        edges(m,:)=[min(edges(m,:)),max(edges(m,:))];%#ok<AGROW>
    end
    [edges,ia,ic]=unique(edges,'rows','stable');%#ok<ASGLU>


    warnState=warning('Off','MATLAB:delaunayTriangulation:DupConsWarnId');
    dt=delaunayTriangulation(P,edges);
    t=dt.ConnectivityList;


    warning(warnState);

    if RefineContours

        [P,t,eCellIntN,refinedNodes]=em.internal.meshprinting.inter8_full_mesh(P,t(:,1:3),...
        eCellIntN,feed,...
        Epsilon);





        edges=[];
        for m=1:size(eCellIntN,2)
            edges=[edges;eCellIntN{m}];%#ok<AGROW>
        end
        for m=1:size(edges,1)
            edges(m,:)=[min(edges(m,:)),max(edges(m,:))];%#ok<AGROW>
        end
        [edges,ia,ic]=unique(edges,'rows','stable');%#ok<ASGLU>



        ContourNodes=unique([edges(:,1);edges(:,2)]);
        moveNodes=setdiff(1:size(P,1),unique([ContourNodes;refinedNodes']));
    else
        moveNodes=[I+1:size(P,1)];
    end


    if~isequal(iter,0)

        P(:,3)=0;
        for m=1:iter
            [P,tsm]=em.internal.meshprinting.meshlaplace(P,t,moveNodes,1,0.25,edges);
        end
        P(:,3)=[];
        t=tsm;
    end


