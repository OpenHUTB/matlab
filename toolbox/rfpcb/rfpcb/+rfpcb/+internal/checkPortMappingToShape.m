function newPortMap=checkPortMappingToShape(L1,feedLoc1,L2,feedLoc2)

    endverts1=L1.EndVertices(:,1:2);
    endverts2=L2.EndVertices(:,1:2);




    id1=find(round(vecnorm(endverts1-feedLoc1(1:2),2,2),15)<=sqrt(eps));
    id2=find(round(vecnorm(endverts2-feedLoc2(1:2),2,2),15)<=sqrt(eps));

    if isempty(id1)||isempty(id2)
        error(message('rfpcb:rfpcberrors:Unsupported','Feed location specified','pcbcascade'));
    end
    newPortMap=[id1,id2];

