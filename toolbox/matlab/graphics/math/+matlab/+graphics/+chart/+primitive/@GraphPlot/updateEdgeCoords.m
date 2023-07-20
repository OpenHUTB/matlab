function[edgeCoords,edgeCoordsIndex]=updateEdgeCoords(hObj)




    nrNodes=numnodes(hObj.BasicGraph_);
    nrEdges=numedges(hObj.BasicGraph_);
    ed=hObj.BasicGraph_.Edges;
    s=ed(:,1);
    t=ed(:,2);
    nc=[hObj.XData_I(:),hObj.YData_I(:),hObj.ZData_I(:)];





    isSelfloop=s==t;
    nrSelfloops=sum(isSelfloop);


    multSelfloop=accumarray(s,double(isSelfloop),[nrNodes,1]);


    [selfLoopRadius,minRadius]=computeSelfLoopRadius(hObj);



    [alpha,ismultedge]=computeOpeningAngle(hObj,selfLoopRadius,minRadius);
    nrMultedges=sum(ismultedge);


    isstraightedge=~(isSelfloop|ismultedge);
    nrStraightedges=length(s)-nrSelfloops-nrMultedges;





    nptsSelfloop=37;
    nptsMultedge=40;
    nptsStraightedge=2;


    nrPoints=nrSelfloops*nptsSelfloop+nrStraightedges*nptsStraightedge...
    +nrMultedges*nptsMultedge;
    edgeCoords=zeros(nrPoints,3);


    nptsEdge=2*ones(nrEdges,1);
    nptsEdge(isSelfloop)=nptsSelfloop;
    nptsEdge(ismultedge)=nptsMultedge;


    edgeCoordsIndex=repelem(1:nrEdges,nptsEdge).';





    blockStart=[0;cumsum(nptsEdge)]+1;
    blockStartStraight=blockStart(isstraightedge);
    blockStartStraight=reshape(blockStartStraight,1,[]);


    edgeCoords(blockStartStraight,:)=nc(s(isstraightedge),:);
    edgeCoords(blockStartStraight+1,:)=nc(t(isstraightedge),:);


    selfloopCount=ones(size(multSelfloop));
    for i=reshape(find(isSelfloop),1,[])
        currentnode=s(i);


        if strcmp(hObj.Layout_,'circle')
            angle=atan2d(hObj.YData_I(currentnode),hObj.XData_I(currentnode));
        else

            if hObj.IsDirected_
                n=unique([successors(hObj.BasicGraph_,currentnode);...
                predecessors(hObj.BasicGraph_,currentnode)]);
            else
                n=neighbors(hObj.BasicGraph_,currentnode);
            end
            n(n==currentnode)=[];

            if~isempty(n)


                diffX=hObj.XData_I(n)-hObj.XData_I(currentnode);
                diffY=hObj.YData_I(n)-hObj.YData_I(currentnode);

                angles=atan2d(diffY,diffX);

                angles=sort(angles);
                angles(end+1)=angles(1)+360;%#ok<AGROW>


                [~,ind]=max(diff(angles));
                ind=ind(1);
                angle=(angles(ind)+angles(ind+1))/2;
            else
                angle=0;
            end
        end



        circle=constructCircle(selfloopCount(currentnode),multSelfloop(currentnode),selfLoopRadius);


        rotcircle=circle*[cosd(angle),sind(angle),0;-sind(angle),cosd(angle),0;0,0,1];


        edgeCoords(blockStart(i):blockStart(i+1)-1,:)=rotcircle+nc(currentnode,:);


        selfloopCount(currentnode)=selfloopCount(currentnode)+1;
    end



    for i=reshape(find(ismultedge),1,[])


        startP=nc(s(i),:);
        endP=nc(t(i),:);

        if alpha(i)~=0

            r=norm(startP(1:2)-endP(1:2))/2/sind(alpha(i)/2);



            d=startP-endP;
            d=[-d(2),d(1),0];
            d=d/norm(d);


            c=(startP+endP)/2-d*r*cosd(alpha(i)/2);


            phi=linspace(-alpha(i)/2,alpha(i)/2,nptsMultedge).';


            pts=r*[cosd(phi),sind(phi)]*[d(1),d(2);-d(2),d(1)];



            pts=[pts+c(1:2),linspace(startP(3),endP(3),nptsMultedge)'];



            pts(1,:)=startP.';
            pts(end,:)=endP.';
        else

            lincoord=linspace(0,1,blockStart(i+1)-blockStart(i));
            pts=interp1([0,1],[startP;endP],lincoord);
        end


        edgeCoords(blockStart(i):blockStart(i+1)-1,:)=pts;
    end


    function[selfLoopRadius,minRadius]=computeSelfLoopRadius(hObj)









        n=numnodes(hObj.BasicGraph_);
        el=hObj.BasicGraph_.Edges;
        nc=[hObj.XData_I(:),hObj.YData_I(:)];

        t=el(:,1);
        h=el(:,2);

        isselfloop=t==h;

        if~strcmp(hObj.Layout_,'circle')



            bb=max(nc,[],1)-min(nc,[],1);
            ncdiff=nc(t(~isselfloop),:)-nc(h(~isselfloop),:);
            mindist=min(hypot(ncdiff(:,1),ncdiff(:,2)));
            selfLoopRadius=mindist/5;


            if isempty(selfLoopRadius)
                if~isempty(bb)&&bb(1)*bb(2)>0

                    selfLoopRadius=sqrt(bb(1)*bb(2)/(4*n*pi));
                else
                    selfLoopRadius=0;
                end
            end

            if any(bb~=0)



                len=min(bb(bb~=0));
                maxRadius=len/6;
                minRadius=len/50;
                selfLoopRadius=min(selfLoopRadius,maxRadius);
                selfLoopRadius=max(selfLoopRadius,minRadius);
            else

                minRadius=0;
                selfLoopRadius=1;
            end

        else
            openingAngle=360/n;



            selfLoopRadius=sind(openingAngle/4)/(1-sind(openingAngle/4));


            len=2;
            minRadius=len/50;
            maxRadius=0.5;

            selfLoopRadius=min(selfLoopRadius,maxRadius);
            selfLoopRadius=max(selfLoopRadius,minRadius);
        end


        function[alpha,isMultedge]=computeOpeningAngle(hObj,selfLoopRadius,minRadius)





            nrNodes=numnodes(hObj.BasicGraph_);
            nrEdges=numedges(hObj.BasicGraph_);
            ed=hObj.BasicGraph_.Edges;
            s=ed(:,1);
            t=ed(:,2);



            edgeMult=sparse(t,s,1,nrNodes,nrNodes);
            edgeMult=edgeMult+edgeMult';
            edgeMult=full(edgeMult(sub2ind(size(edgeMult),s,t)));

            isMultedge=(edgeMult>1)&(s~=t);

            edgeind=matlab.internal.graph.simplifyEdgeIndex(hObj.BasicGraph_);


            firstEdgeMult(flip(edgeind))=length(edgeind):-1:1;


            edgeMultIndex=cumsum(isMultedge);
            edgeMultIndex=edgeMultIndex-edgeMultIndex(firstEdgeMult(edgeind));


            angleScaling=(edgeMult-1-2*edgeMultIndex)./(edgeMult-1);


            maxCycDist=2*selfLoopRadius;
            minCycDist=2*minRadius;
            alphaMin=1e-4;
            alphaMax=30;
            alphaMaxAbsolute=150;


            ed=ed(isMultedge,:);
            xdist=abs(diff(hObj.XData(ed),[],2));
            ydist=abs(diff(hObj.YData(ed),[],2));
            len=hypot(xdist,ydist);




            alphaMaxDist=4*atand(maxCycDist./len);

            alphaBetween=min(2*atand(ydist./xdist),2*atand(xdist./ydist));



            alphaComb=min([alphaMaxDist,alphaBetween],[],2);
            alphaComb=min(alphaComb,alphaMax);


            alphaMinDist=4*atand(minCycDist./len);
            alphaComb=max(alphaComb,alphaMinDist);


            alphaComb=min(alphaComb,alphaMaxAbsolute);


            alphaComb(len==0)=0;


            alphaComb(alphaComb<alphaMin)=0;


            alpha=nan(nrEdges,1);
            alpha(isMultedge)=alphaComb;

            alpha=alpha.*angleScaling;

            function circle=constructCircle(ind,n,selfLoopRadius)


                aWithMargin=45;
                a=aWithMargin/n*0.9;
                rotang=((2*ind-1)/n-1)*aWithMargin;



                r=2*sind(a)*(cosd(rotang)-sind(a))/cosd(a)^2;

                ang=linspace(90-a,270+a,35).';
                circle=selfLoopRadius*[0,0,0;(r/sind(a)-r*cosd(ang)),r*sind(ang),zeros(35,1);0,0,0];

                circle=circle*[cosd(rotang),sind(rotang),0;-sind(rotang),cosd(rotang),0;0,0,1];
