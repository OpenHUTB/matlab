function[maxEdgeLength,minEdgeLength]=findEdgeLength(p,t)


    tr=triangulation(t(1:3,:)',p');


    e=edges(tr);


    edgeLength=sqrt((tr.Points(e(:,2),1)-tr.Points(e(:,1),1)).^2+...
    (tr.Points(e(:,2),2)-tr.Points(e(:,1),2)).^2+...
    (tr.Points(e(:,2),3)-tr.Points(e(:,1),3)).^2);


    maxEdgeLength=max(edgeLength);
    minEdgeLength=min(edgeLength);
