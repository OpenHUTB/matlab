


function edgeLengths=computeEdgeLengths(P,t)
    edgeVectors=P(t(:,1),:)-P(t(:,2),:);
    edgeVectors=[edgeVectors;P(t(:,2),:)-P(t(:,3),:)];
    edgeVectors=[edgeVectors;P(t(:,1),:)-P(t(:,3),:)];

    edgeLengths=vecnorm(edgeVectors,2,2);
end
