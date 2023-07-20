function[BorderTriangles,BorderEdges,BorderNodes]=meshborder(t)










    edges=em.internal.meshprinting.meshconnee(t);
    AttachedTriangles=em.internal.meshprinting.meshconnet(t,edges,'');
    BorderTriangles=[];
    for m=1:size(edges,1)
        if length(AttachedTriangles{m})==1
            BorderTriangles=[BorderTriangles,AttachedTriangles{m}];
        end
    end
    BorderTriangles=unique(BorderTriangles);


    se=em.internal.meshprinting.meshconnte(t,edges);
    BorderEdges=unique([se(BorderTriangles,1),se(BorderTriangles,2),se(BorderTriangles,3)]);


    nodes=[];
    for m=1:size(edges,1)
        if length(AttachedTriangles{m})==1
            nodes=[nodes,edges(m,:)];
        end
    end
    BorderNodes=unique(nodes);

end
