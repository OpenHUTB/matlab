function metalbasis=overrideFeedEdgeBasis(obj,metalbasis,p,t)


    if(isa(obj,'rfpcb.PrintedLine'))
        [~,ef,~,~]=obj.getFeedAndViaState();
        stack=obj.getPrintedStack;
    else
        [~,ef]=obj.getFeedState();
        stack=obj;
    end

    if(~any(ef))
        return;
    end


    feedLocs=stack.modifiedFeedLocations(ef,:);


    if~isempty(stack.FeedEdgeCenters)
        feedEdgeLocs=stack.FeedEdgeCenters(ef);
    else
        temp=obj.FeedLocation(ef,:);
        rowsTemp=ones(size(temp,1),1);
        feedEdgeLocs=mat2cell(temp,rowsTemp);
    end


    P=transpose(p);
    t=transpose(t);
    normals=transpose(metalbasis.Normal);
    triangleCenters=(P(t(:,1),:)+P(t(:,2),:)+P(t(:,3),:))/3;


    edgesdup=[t(:,[1,2]);t(:,[1,3]);t(:,[2,3])];
    e1=sort(edgesdup,2);
    [edges,eia(:,1)]=unique(e1,'rows');
    [~,eia(:,2)]=unique(e1,'last','rows');


    e2t=mod(eia-1,size(t,1))+1;
    e2t=sort(e2t,2);


    edgeCenters=(P(edges(:,1),:)+P(edges(:,2),:))/2;


    layerHeights=calculateLayerZCoords(stack);


    e2t_forced=cell(size(feedLocs,1),1);
    edgesFeed=cell(size(feedLocs,1),1);
    edgesGnd=cell(size(feedLocs,1),1);

    for k=1:size(feedLocs,1)


        if isa(obj,'stripLine')

            groundPlaneEquation=[0,0,-1,stack.BoardThickness;0,0,1,0];
        else

            fromLayer=feedLocs(k,3);
            toLayer=feedLocs(k,4);
            sgn=sign(layerHeights(fromLayer)-layerHeights(toLayer));
            groundPlaneEquation=[0,0,sgn,-layerHeights(toLayer)];
        end


        e2t_forced{k}=cell(size(groundPlaneEquation,1));
        edgesFeed{k}=cell(size(groundPlaneEquation,1));
        edgesGnd{k}=cell(size(groundPlaneEquation,1));



        for j=1:size(groundPlaneEquation,1)

            kdt1=KDTreeSearcher(edgeCenters);
            [edgesFeedIndices,D]=knnsearch(kdt1,feedEdgeLocs{k});
            edgesFeed{k}{j}=edges(edgesFeedIndices,:);


            feedTrianglesCandidates=e2t(edgesFeedIndices,:);
            normVec1=normals(feedTrianglesCandidates(:,1),:);
            normVec2=normals(feedTrianglesCandidates(:,2),:);

            groundPlaneNormal=groundPlaneEquation(j,1:3)/norm(groundPlaneEquation(j,1:3));
            dot1=abs(dot(normVec1,repmat(groundPlaneNormal,size(normVec1,1),1),2));
            dot2=abs(dot(normVec2,repmat(groundPlaneNormal,size(normVec2,1),1),2));

            firstTriangleGood=dot1>dot2;
            e2t_forced{k}{j}(firstTriangleGood,1)=feedTrianglesCandidates(firstTriangleGood,1);
            e2t_forced{k}{j}(~firstTriangleGood,1)=feedTrianglesCandidates(~firstTriangleGood,2);


            feedTriangleCenters=triangleCenters(e2t_forced{k}{j}(:,1),:);
            distFromPlane=abs(feedTriangleCenters*transpose(groundPlaneEquation(j,1:3))+groundPlaneEquation(j,4))/norm(groundPlaneEquation(j,1:3));
            feedTriangleCentersProjected=feedTriangleCenters-repmat(distFromPlane,1,3).*repmat(groundPlaneNormal,length(distFromPlane),1);



            kdt2=KDTreeSearcher(triangleCenters);
            [e2t_forced{k}{j}(:,2),D]=knnsearch(kdt2,feedTriangleCentersProjected);


            distFromPlane=abs(feedEdgeLocs{k}*transpose(groundPlaneEquation(j,1:3))+groundPlaneEquation(j,4))/norm(groundPlaneEquation(j,1:3));
            feedLocationsProjected=feedEdgeLocs{k}-repmat(distFromPlane,1,3).*repmat(groundPlaneNormal,length(distFromPlane),1);

            kdt3=KDTreeSearcher(edgeCenters);
            [edgesFeedIndices,D]=knnsearch(kdt3,feedLocationsProjected);

            edgesGnd{k}{j}=edges(edgesFeedIndices,:);
        end

        e2t_forced{k}=vertcat(e2t_forced{k}{:});
        edgesFeed{k}=vertcat(edgesFeed{k}{:});
        edgesGnd{k}=vertcat(edgesGnd{k}{:});
    end

    e2t_new=vertcat(e2t_forced{:});
    edgesP_new=vertcat(edgesFeed{:});
    edgesM_new=vertcat(edgesGnd{:});


    metalbasis.TrianglePlus=[metalbasis.TrianglePlus,transpose(e2t_new(:,1)-1)];
    metalbasis.TriangleMinus=[metalbasis.TriangleMinus,transpose(e2t_new(:,2)-1)];

    metalbasis.Edges=[metalbasis.Edges,transpose(edgesP_new)];

    edgeSum=sum(edgesP_new,2);
    verPToAdd_absolute=sum(t(e2t_new(:,1),1:3),2)-edgeSum;

    edgeSum=sum(edgesM_new,2);
    verMToAdd_absolute=sum(t(e2t_new(:,2),1:3),2)-edgeSum;


    verPToAdd=verPToAdd_absolute;
    verMToAdd=verMToAdd_absolute;
    for j=1:length(verPToAdd_absolute)
        verPToAdd(j)=find(t(e2t_new(j,1),1:3)==verPToAdd_absolute(j));
        verMToAdd(j)=find(t(e2t_new(j,2),1:3)==verMToAdd_absolute(j));
    end

    metalbasis.VerP=[metalbasis.VerP,transpose(verPToAdd-1)];
    metalbasis.VerM=[metalbasis.VerM,transpose(verMToAdd-1)];


    if 0
        plot_dbStack=dbstack;disp(['Debug plot active on line ',num2str((plot_dbStack(1).line)),' of ',plot_dbStack(1).file]);%#ok
        figure;

        temp=triangleCenters(:,3)>1e-5;
        p1=patch('vertices',P,'faces',t(temp,1:3));hold on;
        p1.FaceColor=[1,1,1];
        p1.EdgeColor='k';
        p1.FaceAlpha=1.0;
        p2=patch('vertices',P,'faces',t(~temp,1:3));
        p2.FaceColor=double([0xB0,0xC4,0xDE])/255.0;
        p2.EdgeColor='k';
        p2.FaceAlpha=1.0;



        colors=repmat([1,0,0;0.5,1,0;0,0,1],30,1);
        colors=prism(size(e2t_new,1));
        for m=1:size(e2t_new,1)
            patch('vertices',P,'faces',t(e2t_new(m,:),1:3),'FaceColor',colors(m,:),'EdgeColor','k','FaceAlpha',0.5);
            P_plot_1=P(edgesP_new(m,1),:);
            P_plot_2=P(edgesP_new(m,2),:);

            plot3(P_plot_1(:,1),P_plot_1(:,2),P_plot_1(:,3),'*r','MarkerSize',12);
            plot3(P_plot_2(:,1),P_plot_2(:,2),P_plot_2(:,3),'*b','MarkerSize',12);

        end
        for m=1:length(feedEdgeLocs)
            plot3(feedEdgeLocs{m}(:,1),feedEdgeLocs{m}(:,2),feedEdgeLocs{m}(:,3),'*g','MarkerSize',12);

        end

        view(88,90);xlabel('x, m');ylabel('y, m');zlabel('z, m');
        axis equal;axis tight;set(gcf,'Color','White');
        title('Feed edge pseudo-bases, triangle plot')


        figure;

        p=patch('vertices',P,'faces',t(:,1:3));hold on;
        p.FaceColor=[1,1,1];
        p.EdgeColor='k';
        p.FaceAlpha=1.0;


        for m=1:size(e2t_new,1)
            point1=P(edgesP_new(m,1),:);
            point2=P(edgesP_new(m,2),:);
            line([point1(1),point2(1)],[point1(2),point2(2)],[point1(3),point2(3)],'Color',colors(m,:));

            point1=P(edgesM_new(m,1),:);
            point2=P(edgesM_new(m,2),:);
            line([point1(1),point2(1)],[point1(2),point2(2)],[point1(3),point2(3)],'Color',colors(m,:));
        end


        view(88,90);xlabel('x, m');ylabel('y, m');zlabel('z, m');
        axis equal;axis tight;set(gcf,'Color','White');
        title('Feed edge pseudo-bases, edge plot')
    end
end