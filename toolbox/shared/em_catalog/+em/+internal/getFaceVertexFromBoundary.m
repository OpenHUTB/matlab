function[f,v]=getFaceVertexFromBoundary(Ppoly,Phole,numHoles)


    if~isequal(numHoles,0)
        X=[Ppoly(:,1);Phole(:,1)];
        Y=[Ppoly(:,2);Phole(:,2)];
        [f,v]=em.internal.polygonToFaceVertex(X,Y);
    else
        [f,v]=em.internal.polygonToFaceVertex(Ppoly(:,1),Ppoly(:,2));
    end