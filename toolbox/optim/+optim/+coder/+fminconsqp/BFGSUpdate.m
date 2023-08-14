function[success,Bk,yk,workspace]=BFGSUpdate(nvar,Bk,sk,yk,workspace)
































%#codegen

    coder.allowpcode('plain');


    validateattributes(nvar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(Bk,{'double'},{'2d'});
    validateattributes(sk,{'double'},{'vector'});
    validateattributes(yk,{'double'},{'vector'});
    validateattributes(workspace,{'double'},{'2d'});

    POSDEF_TOL=0.2;
    INT_ONE=coder.internal.indexInt(1);
    ldBk=coder.internal.indexInt(size(Bk,1));


    dotSY=coder.internal.blas.xdot(nvar,sk,INT_ONE,INT_ONE,yk,INT_ONE,INT_ONE);


    workspace=coder.internal.blas.xgemv('N',nvar,nvar,1.0,Bk,INT_ONE,ldBk,sk,INT_ONE,INT_ONE,0.0,workspace,INT_ONE,INT_ONE);
    curvatureS=coder.internal.blas.xdot(nvar,sk,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE);


    if(dotSY<POSDEF_TOL*curvatureS)
        theta=(1-POSDEF_TOL)*curvatureS/(curvatureS-dotSY);


        yk=coder.internal.blas.xscal(nvar,theta,yk,INT_ONE,INT_ONE);
        theta=1-theta;
        yk=coder.internal.blas.xaxpy(nvar,theta,workspace,INT_ONE,INT_ONE,yk,INT_ONE,INT_ONE);


        dotSY=coder.internal.blas.xdot(nvar,sk,INT_ONE,INT_ONE,yk,INT_ONE,INT_ONE);
    end






    success=(curvatureS>eps('double')&&dotSY>eps('double'));
    if(success)







        multiplier=-1.0/curvatureS;
        Bk=coder.internal.blas.xger(nvar,nvar,multiplier,workspace,INT_ONE,INT_ONE,workspace,INT_ONE,INT_ONE,Bk,INT_ONE,ldBk);


        multiplier=1.0/dotSY;
        Bk=coder.internal.blas.xger(nvar,nvar,multiplier,yk,INT_ONE,INT_ONE,yk,INT_ONE,INT_ONE,Bk,INT_ONE,ldBk);

    end

end

