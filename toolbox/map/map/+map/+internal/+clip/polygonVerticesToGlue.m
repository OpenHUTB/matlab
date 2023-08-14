function[efirst,elast,eskip]=polygonVerticesToGlue(x,y,xlimits)












    edgesWest=find(x==xlimits(1));
    edgesEast=find(x==xlimits(2));
    if isempty(edgesWest)||isempty(edgesEast)
        efirst=[];
        elast=[];
        eskip=[];
    else


        [westseg1,westseg2,eastseg1,eastseg2,yWest1,yWest2,...
        yEast1,yEast2]=findAndSortEdgeSegments(edgesWest,edgesEast,y);



        [overlapWest,overlapEast]=analyzeOverlap(yWest1,yWest2,yEast1,yEast2);



        west1=westseg1(overlapWest);
        west2=westseg2(overlapWest);

        east1=eastseg1(overlapEast);
        east2=eastseg2(overlapEast);



        eskip=[intersect(west1,west2);intersect(east1,east2)];


        [elast,efirst]=organizeConnections(west1,west2,east1,east2,y);


        [elast,ilast]=sort(elast);
        efirst=efirst(ilast);
    end
end


function[westseg1,westseg2,eastseg1,eastseg2,yWest1,yWest2,...
    yEast1,yEast2]=findAndSortEdgeSegments(edgesWest,edgesEast,y)



    n=length(y);
    [first,last]=internal.map.findFirstLastNonNan(y);
    [westseg1,westseg2]=findEdgeSegments(edgesWest,n,first,last);
    [eastseg1,eastseg2]=findEdgeSegments(edgesEast,n,first,last);

    yWest1=y(westseg1);
    yEast1=y(eastseg1);

    [yWest1,iWest]=sort(yWest1);
    [yEast1,iEast]=sort(yEast1);

    westseg1=westseg1(iWest);
    westseg2=westseg2(iWest);

    eastseg1=eastseg1(iEast);
    eastseg2=eastseg2(iEast);

    yWest2=y(westseg2);
    yEast2=y(eastseg2);


    assert(all(yWest1<=yWest2),...
    'map:gluingPolygon:expectedDecreasingY',...
    'Assert failed: Expected increasing y in segments along western edge.')

    assert(all(yEast1>=yEast2),...
    'map:gluingPolygon:expectedIncreasingY',...
    'Assert failed: Expected increasing y in segments along eastern edge.')
end


function[seg1,seg2]=findEdgeSegments(edges,n,first,last)









    adjacent=find(diff(edges)==1);
    seg1=edges(adjacent);
    seg2=edges(adjacent+1);



    if n>2
        for k=1:numel(first)
            if any(first(k)==edges)&&any(last(k)==edges)
                seg1=[seg1;last(k)];%#ok<AGROW>
                seg2=[seg2;first(k)];%#ok<AGROW>
            end
        end
    end
end


function[overlapWest,overlapEast]=analyzeOverlap(yWest1,yWest2,yEast1,yEast2)





    overlapWest=false(size(yWest1));
    overlapEast=false(size(yEast1));

    w=1;
    e=1;
    while(w<=length(yWest1))&&(e<=length(yEast1))
        if yWest2(w)<=yEast2(e)

            w=w+1;
        elseif yEast1(e)<=yWest1(w)

            e=e+1;
        else

            overlapWest(w)=true;
            overlapEast(e)=true;

            if yWest2(w)<yEast1(e)
                w=w+1;
            elseif yEast1(e)<yWest2(w)
                e=e+1;
            else


                w=w+1;
                e=e+1;
            end
        end
    end
end


function[elast,efirst]=organizeConnections(west1,west2,east1,east2,y)




    elast=[setdiff(west1,west2);setdiff(east1,east2)];
    efirst=[setdiff(west2,west1);setdiff(east2,east1)];
    [~,iLast]=sort(y(elast));
    [~,iFirst]=sort(y(efirst));
    elast=elast(iLast);
    efirst=efirst(iFirst);
end
