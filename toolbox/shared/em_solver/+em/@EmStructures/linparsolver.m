function linparsolver(obj,frequency)

    c=em.FieldSolver2d;
    savelinpar(c,obj.SolverStruct.FieldSolver2d);

    dir=tempdir;
    generateCFG(c,frequency,dir);
    Mesh=createMesh(c);
    generateLPARIN(c,Mesh,dir);

    [solution,~]=solve(c,dir);

    savelinparsolution(obj,frequency,solution);

end