function edges=meshconnee(t)










    edges=[t(:,[1,2]);t(:,[1,3]);t(:,[2,3])];
    edges=unique(sort(edges,2),'rows');
end


