function[xg,yg]=gluePolygonOnCylinder(x,y,xlimits)










    ex=zeros([0,0],'like',x);
    ey=zeros([0,0],'like',y);

    if all(isnan(x))
        x=ex;
        y=ey;
    end

    [x,y]=removeExtraNanSeparators(x,y);
    if isempty(x)
        xg=ex;
        yg=ey;
        return
    end


    if(xlimits(1)<min(x))||(max(x)<xlimits(2))
        xg=x;
        yg=y;
        return
    end

    x=x(:);
    y=y(:);

    [efirst,elast,eskip]=map.internal.clip.polygonVerticesToGlue(x,y,xlimits);
    [xg,yg]=linkPolygonParts(x,y,xlimits,efirst,elast,eskip);
end


function[xg,yg]=linkPolygonParts(x,y,xlimits,efirst,elast,eskip)





    [x,y,efirst,elast]=removeVerticesToSkip(x,y,efirst,elast,eskip);








    xg=NaN(size(x),'like',x);
    yg=NaN(size(y),'like',y);




    [first,last]=internal.map.findFirstLastNonNan(x);










    [first,~,next]=unique([first;efirst]);
    [last,iLast]=unique([last;elast]);
    next=next(iLast);



    numPieces=numel(first);
    numTraced=0;

    n=1;
    traced=false(numPieces,1);
    for k=1:numPieces
        if~traced(k)
            kFirst=first(k);
            lastxg=NaN('like',x);
            lastyg=NaN('like',y);



            j=k;
            while~traced(j)


                numTraced=numTraced+1;
                assert(numTraced<=numPieces,...
                'map:gluePolygonsOnVerticalEdges:tracingFailed',...
                'Failed to converge when tracing open curves.')

                jFirst=first(j);
                bothOnEdge=any(x(jFirst)==xlimits)&&any(lastxg==xlimits);
                firstIsDuplicate=(y(jFirst)==lastyg)...
                &&(x(jFirst)==lastxg||bothOnEdge);
                if firstIsDuplicate


                    s=1+jFirst;
                else

                    s=jFirst;
                end

                e=last(j);
                m=n+e-s;
                xg(n:m)=x(s:e);
                yg(n:m)=y(s:e);


                traced(j)=true;
                j=next(j);
                lastxg=xg(m);
                lastyg=yg(m);
                n=m+1;
            end


            bothOnEdge=any(x(kFirst)==xlimits)&&any(lastxg==xlimits);
            if(lastyg~=y(kFirst))||(lastxg~=x(kFirst)&&~bothOnEdge)
                xg(n)=x(kFirst);
                yg(n)=y(kFirst);
                n=n+1;
            end



            xg(n)=NaN;
            yg(n)=NaN;
            n=n+1;
        end
    end


    k=length(xg);
    while isnan(xg(k))
        xg(k)=[];
        yg(k)=[];
        k=k-1;
    end
end


function[x,y,efirst,elast]=removeVerticesToSkip(x,y,efirst,elast,eskip)




    s=zeros(size(x));
    s(eskip)=1;
    skipcount=cumsum(s);

    efirst=efirst-skipcount(efirst);
    elast=elast-skipcount(elast);

    x(eskip)=[];
    y(eskip)=[];
end
