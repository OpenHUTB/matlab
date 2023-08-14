function[x,y]=closePolygonInRectangle(x,y,xlimits,ylimits)

















    x=x(:);
    y=y(:);
    if~isempty(x)
        [xTraced,yTraced]=traceAllOpenCurves(x,y,xlimits,ylimits);
        [x,y]=removeCurvesWithEndpointsOnBoundary(x,y,xlimits,ylimits);
        x=[xTraced;x];
        y=[yTraced;y];
    end



    function[xTraced,yTraced]=traceAllOpenCurves(x,y,xlimits,ylimits)



        [first,last]=findCurvesWithEndpointsOnBoundary(x,y,xlimits,ylimits);
        [x,y,first,last]=removeIsolatedVertices(x,y,first,last);







        numOpenCurves=numel(first);
        traced=false(numOpenCurves,1);
        maxNumVertices=numel(x)+6*numOpenCurves;
        xTraced=NaN([maxNumVertices,1],'like',x);
        yTraced=NaN([maxNumVertices,1],'like',y);


        xCorner=xlimits([1,1,2,2])';
        yCorner=ylimits([1,2,2,1])';

        [startPointRanks,endPointRanks,cornerRanks]=rankPointsOnBoundary(...
        x(first),y(first),x(last),y(last),xCorner,yCorner,xlimits,ylimits);

        startingEdge=edge(x(first),y(first),xlimits,ylimits);


        n=1;
        for k=1:numOpenCurves
            if~traced(k)
                [xTraced,yTraced,m,traced]=traceSimplePolygon(...
                xTraced,yTraced,n,k,traced,x,y,first,last,startingEdge,...
                startPointRanks,endPointRanks,cornerRanks,xCorner,yCorner);
                n=m+2;
            end
        end


        xTraced(n:end)=[];
        yTraced(n:end)=[];


        duplicate=(xTraced(1:end-1)==xTraced(2:end))...
        &(yTraced(1:end-1)==yTraced(2:end));
        xTraced(duplicate)=[];
        yTraced(duplicate)=[];



        function[xTraced,yTraced,m,traced]=traceSimplePolygon(...
            xTraced,yTraced,n,k,traced,x,y,first,last,startingEdge,...
            startPointRanks,endPointRanks,cornerRanks,xCorner,yCorner)








            numUntracedCurves=sum(~traced);

            j=k;
            done=false;
            numTraced=0;
            nFirst=n;
            while~done

                map.internal.assert(numTraced<numUntracedCurves,...
                'map:topology:tracingFailedToConverge')


                s=first(j);
                e=last(j);
                m=n+e-s;
                xTraced(n:m)=x(s:e);
                yTraced(n:m)=y(s:e);


                [j,corners]=findNextCurve(e,x,y,first,startingEdge,...
                startPointRanks,endPointRanks(j),cornerRanks,traced);


                n=m+1;
                m=m+numel(corners);
                xTraced(n:m)=xCorner(corners);
                yTraced(n:m)=yCorner(corners);
                n=m+1;





                traced(j)=true;
                numTraced=numTraced+1;
                done=(j==k);
            end


            numVertices=m-nFirst+1;
            if(numVertices>2)...
                &&((xTraced(m)~=xTraced(nFirst))||(yTraced(m)~=yTraced(nFirst)))
                m=m+1;
                xTraced(m)=xTraced(nFirst);
                yTraced(m)=yTraced(nFirst);
            end



            function[j,corners]=findNextCurve(e,x,y,first,startingEdge,...
                startPointRanks,endPointRank,cornerRanks,traced)

















                j=[];
                untraced=~traced;
                q=(startPointRanks==endPointRank)&untraced;
                if any(q)







                    u=x(e)-x(e-1);
                    v=y(e)-y(e-1);

                    j=curveWithSharpestRightTurn(find(q),u,v,x,y,first);
                    corners=[];
                end

                if isempty(j)


                    startPointRank=traverseRankClockwise(startPointRanks(untraced),endPointRank);
                    j=find((startPointRanks==startPointRank)&untraced);
                    [u,v]=directionAlongEdge(j(1),startingEdge);
                    j=curveWithSharpestRightTurn(j,u,v,x,y,first);
                    corners=cornersTraversed(endPointRank,startPointRank,cornerRanks);
                end



                function startPointRank=traverseRankClockwise(startPointRanks,endPointRank)



                    ranks=sort(startPointRanks);
                    q=(ranks>endPointRank);
                    if any(q)
                        startPointRank=ranks(find(q,1,'first'));
                    else

                        startPointRank=ranks(1);
                    end



                    function k=edge(x,y,xlimits,ylimits)





                        k=zeros(size(x));

                        k(x==xlimits(1)&y>ylimits(1))=1;
                        k(y==ylimits(2)&x>xlimits(1))=2;
                        k(x==xlimits(2)&y<ylimits(2))=3;
                        k(y==ylimits(1)&x<xlimits(2))=4;



                        function[u,v]=directionAlongEdge(j,startingEdge)
                            k=startingEdge(j(1));
                            u0=[0,1,0,-1];
                            v0=[1,0,-1,0];
                            u=u0(k);
                            v=v0(k);



                            function j=curveWithSharpestRightTurn(j,u,v,x,y,first)





                                if~isempty(j)


                                    n=first(j);
                                    a=x(n+1)-x(n);
                                    b=y(n+1)-y(n);






                                    theta=atan2(v*a-u*b,-u*a-v*b);




                                    q=(theta>=0);

                                    if any(q)


                                        j=j(q);
                                        [~,indx]=sort(theta(q));
                                        j=j(indx(1));
                                    else

                                        j=[];
                                    end
                                end



                                function corners=cornersTraversed(endPointRank,startPointRank,cornerRanks)




                                    if endPointRank<startPointRank

                                        corners=find(endPointRank<cornerRanks&cornerRanks<startPointRank);
                                    else

                                        corners=[find(endPointRank<cornerRanks);find(cornerRanks<startPointRank)];
                                    end



                                    function[startPointRanks,endPointRanks,cornerRanks]=rankPointsOnBoundary(...
                                        xStart,yStart,xEnd,yEnd,xCorner,yCorner,xlimits,ylimits)







                                        x=[xStart;xEnd;xCorner];
                                        y=[yStart;yEnd;yCorner];


                                        rank=map.internal.clip.rankPointsOnRectangleBoundary(x,y,xlimits,ylimits);


                                        n=(length(rank)-4)/2;
                                        startPointRanks=rank(1:n);
                                        endPointRanks=rank(n+1:2*n);
                                        cornerRanks=rank((1+2*n):end);



                                        function[first,last]=findCurvesWithEndpointsOnBoundary(x,y,xlimits,ylimits)



                                            [first,last]=internal.map.findFirstLastNonNan(x);

                                            endPointsOnBoundary=...
                                            onBoundary(x(first),y(first),xlimits,ylimits)&...
                                            onBoundary(x(last),y(last),xlimits,ylimits);

                                            first=first(endPointsOnBoundary);
                                            last=last(endPointsOnBoundary);



                                            function[x,y]=removeCurvesWithEndpointsOnBoundary(x,y,xlimits,ylimits)




                                                [first,last]=findCurvesWithEndpointsOnBoundary(x,y,xlimits,ylimits);
                                                for k=1:numel(first)
                                                    x(first(k):last(k))=NaN;
                                                    y(first(k):last(k))=NaN;
                                                end
                                                [x,y]=removeExtraNanSeparators(x,y);



                                                function[x,y,first,last]=removeIsolatedVertices(x,y,first,last)



                                                    isolated=(first==last);
                                                    x(first(isolated))=NaN;
                                                    y(first(isolated))=NaN;
                                                    first(isolated)=[];
                                                    last(isolated)=[];



                                                    function tf=onBoundary(x,y,xlimits,ylimits)



                                                        tf=(x==xlimits(1))|(x==xlimits(2))...
                                                        |(y==ylimits(1))|(y==ylimits(2));
