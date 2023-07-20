function scaledvertices=scaleAxisVertices(Sx,Sy,Sz,vertices)



    K=kron([Sx,Sy,Sz],eye(3,3));

    S=K(:,[1,5,9]);
    scaledvertices=S*vertices;