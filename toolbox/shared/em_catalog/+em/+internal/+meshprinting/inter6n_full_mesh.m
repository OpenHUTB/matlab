function[P,t,edges,pspecial,especial,feedvia_new,feedvia_map]=inter6n_full_mesh(...
    P,eCellInt,minContourLength,feed,via,Epsilon,refineContours,edgeStatus)


    if any(edgeStatus)
        edgeStatus='unsplit';
    end


    edges=vertcat(eCellInt{:});
    edges=sort(edges,2);
    [edges,ia,ic]=unique(edges,'rows','stable');


    if 0
        plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
        figure;plot(P(:,1),P(:,2),'*r');axis equal;hold on;
        for j=1:size(edges,1)
            p_plot=[P(edges(j,1),:);P(edges(j,2),:)];
            plot(p_plot(:,1),p_plot(:,2),'-b');
        end
        plot(feed(:,1),feed(:,2),'og');
        title('Initial input points and edges');
    end


    feed_new=feed;
    feed_map=transpose(1:size(feed,1));

    via_new=via;
    via_map=transpose(1:size(via,1));

    special_edgesv=[];
    edgesToSplit=1;








    while~isempty(edgesToSplit)

        edgeVectors=P(edges(:,1),:)-P(edges(:,2),:);
        edgeLengths=vecnorm(edgeVectors,2,2);
        edgesToSplit=[find(edgeLengths>minContourLength)];



        if~isempty(feed_new)
            [special_edgesf,~]=em.internal.meshprinting.inter10a_full_mesh(P,edges,feed_new,Epsilon);


            tempf=[];
            for m=1:length(special_edgesf)
                tempf=[tempf;find(edgesToSplit==special_edgesf(m))];
            end


            if strcmpi(edgeStatus,'unsplit')
                edgesToSplit(tempf')=[];
            end
        end


        if~isempty(via_new)
            [special_edgesv,~]=em.internal.meshprinting.inter10a_full_mesh(P,edges,via_new,Epsilon);
            tempv=[];
            for m=1:length(special_edgesv)
                tempv=[tempv;find(edgesToSplit==special_edgesv(m))];
            end
            if(strcmpi(edgeStatus,'unsplit'))
                edgesToSplit(tempv')=[];
            end
        end


        eadd=[];
        eremove=[];



        feed_newtemp=mat2cell(feed_new,ones(size(feed_new,1),1),size(feed_new,2));
        feedmap_temp=mat2cell(feed_map,ones(size(feed_map,1),1));
        via_newtemp=mat2cell(via_new,ones(size(via_new,1),1),size(via_new,2));
        viamap_temp=mat2cell(via_map,ones(size(via_map,1),1));

        for m=1:length(edgesToSplit)
            n=edgesToSplit(m);


            edgeMidpoint=0.5*(P(edges(n,1),:)+P(edges(n,2),:));
            P=[P;edgeMidpoint];
            newnode=size(P,1);
            eadd=[eadd;[edges(n,1),newnode];[newnode,edges(n,2)]];


            idx_feed=find(special_edgesf==n);
            if~isempty(idx_feed)
                addedFeeds=0.5*(P(([edges(n,1),newnode]),:)+P(([newnode,edges(n,2)]),:));
                for i=1:numel(idx_feed)
                    feed_newtemp{idx_feed(i)}=addedFeeds;
                    feedmap_temp{idx_feed(i)}=repmat(feed_map(idx_feed(i)),2,1);
                end
            end


            idx_via=find(special_edgesv==n);
            if~isempty(idx_via)
                addedVias=0.5*(P(([edges(n,1),newnode]),:)+P(([newnode,edges(n,2)]),:));
                for i=1:numel(idx_via)
                    via_newtemp{idx_via(i)}=addedVias;
                    viamap_temp{idx_via(i)}=repmat(via_map(idx_via(i)),2,1);
                end
            end

            eremove=[eremove;n];
        end


        edges(eremove,:)=[];
        edges=[edges;eadd];








        if isempty(edgesToSplit)
            specialEdgesToSplit=[];

            [~,~,ic]=unique(feed_map);
            EdgesPerFeed=accumarray(ic,1);
            maxNumSplitEdges=max(EdgesPerFeed);
            feedIdToSplit=find(EdgesPerFeed~=maxNumSplitEdges);

            viaIdToSplit=[];
            if~isempty(via_new)
                [~,~,ic]=unique(via_map);
                EdgesPerVia=accumarray(ic,1);
                maxNumSplitEdges=max(EdgesPerVia);
                viaIdToSplit=find(EdgesPerVia~=maxNumSplitEdges);
            end
            if~isempty(feedIdToSplit)
                if max(EdgesPerFeed)==2
                    specialEdgesToSplit=[specialEdgesToSplit;special_edgesf(feedIdToSplit)];
                else
                    offsetsForIndices=cumsum(EdgesPerFeed);
                    startIndices=[1;offsetsForIndices(1:end-1)+1];
                    stopIndices=[startIndices(2:end)-1;offsetsForIndices(end)];
                    for i=1:numel(feedIdToSplit)
                        specialEdgesToSplit=[specialEdgesToSplit;special_edgesf(startIndices(feedIdToSplit):stopIndices(feedIdToSplit))];
                    end
                end
            end
            if~isempty(viaIdToSplit)
                if max(EdgesPerVia)==2
                    specialEdgesToSplit=[specialEdgesToSplit;special_edgesv(viaIdToSplit)];
                else
                    offsetsForIndices=cumsum(EdgesPerVia);
                    startIndices=[1;offsetsForIndices(1:end-1)+1];
                    stopIndices=[startIndices(2:end)-1;offsetsForIndices(end)];
                    for i=1:numel(viaIdToSplit)
                        specialEdgesToSplit=[specialEdgesToSplit;special_edgesv(startIndices(viaIdToSplit):stopIndices(viaIdToSplit))];
                    end
                end
            end

            for m=1:length(specialEdgesToSplit)
                n=specialEdgesToSplit(m);


                edgeMidpoint=0.5*(P(edges(n,1),:)+P(edges(n,2),:));
                P=[P;edgeMidpoint];
                newnode=size(P,1);
                eadd=[eadd;[edges(n,1),newnode];[newnode,edges(n,2)]];


                idx_feed=find(special_edgesf==n);
                if~isempty(idx_feed)
                    addedFeeds=0.5*(P(([edges(n,1),newnode]),:)+P(([newnode,edges(n,2)]),:));
                    for i=1:numel(idx_feed)
                        feed_newtemp{idx_feed(i)}=addedFeeds;
                        feedmap_temp{idx_feed(i)}=repmat(feed_map(idx_feed(i)),2,1);
                    end
                end


                idx_via=find(special_edgesv==n);
                if~isempty(idx_via)
                    addedVias=0.5*(P(([edges(n,1),newnode]),:)+P(([newnode,edges(n,2)]),:));
                    for i=1:numel(idx_via)
                        via_newtemp{idx_via(i)}=addedVias;
                        viamap_temp{idx_via(i)}=repmat(via_map(idx_via(i)),2,1);
                    end
                end

                eremove=[eremove;n];
            end


            edges(eremove,:)=[];
            edges=[edges;eadd];
        end

        if~strcmpi(edgeStatus,'edgeSplit')
            feed_new=cell2mat(feed_newtemp);
            feed_map=cell2mat(feedmap_temp);
            via_new=cell2mat(via_newtemp);
            via_map=cell2mat(viamap_temp);
        end
    end






    feedvia_new={feed_new,via_new};




    feedvia_map={feed_map,via_map};


    [especialf,~]=em.internal.meshprinting.inter10a_full_mesh(P,edges,feed_new,Epsilon);
    [especialv,~]=em.internal.meshprinting.inter10a_full_mesh(P,edges,via_new,Epsilon);

    pspecialf=P(edges(especialf,:)',:);
    pspecialv=P(edges(especialv,:)',:);

    pspecial={pspecialf,pspecialv};
    especial={especialf,especialv};


    if 0
        plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
        figure;plot(P(:,1),P(:,2),'*r');axis equal;hold on;
        for j=1:size(edges,1)
            p_plot=[P(edges(j,1),:);P(edges(j,2),:)];
            plot(p_plot(:,1),p_plot(:,2),'-b');
        end
        P_orig=P;
    end


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

end