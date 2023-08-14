
function F=boundary_faces(T)












    allF=[...
    T(:,1),T(:,2),T(:,3);...
    T(:,1),T(:,3),T(:,4);...
    T(:,1),T(:,4),T(:,2);...
    T(:,2),T(:,4),T(:,3)];

    sortedF=sort(allF,2);

    [u,m,n]=unique(sortedF,'rows');

    counts=accumarray(n(:),1);

    sorted_exteriorF=u(counts==1,:);

    F=allF(ismember(sortedF,sorted_exteriorF,'rows'),:);
end