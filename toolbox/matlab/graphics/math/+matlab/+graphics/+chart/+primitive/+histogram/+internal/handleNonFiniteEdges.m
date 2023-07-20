function edges=handleNonFiniteEdges(edges)






    isfiniteedges=isfinite(edges);
    nfiniteedges=sum(isfiniteedges);
    if nfiniteedges>=2
        bwf=zeros(0,0,'like',edges);

        if~isfiniteedges(1)
            indf=find(isfiniteedges,1);


            bwf=(edges(indf+1)-edges(indf))*2;
        end
        bwl=zeros(0,0,'like',edges);

        if~isfiniteedges(end)
            indl=find(isfiniteedges,1,'last');


            bwl=(edges(indl)-edges(indl-1))*2;
        end
        edges=edges(isfiniteedges);
        edges=[edges(1)-bwf,edges,edges(end)+bwl];
    else
        edges=edges(isfiniteedges);
        if isempty(edges)
            edges=0;
        end
    end
end