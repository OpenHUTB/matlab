function directStep=solveKKTsystem(KKTfactor,Hess,rhs,sizes,options)












    if~strcmpi(options.HessType,'LBFGS')
        directStep=backsolveSys(KKTfactor,rhs);
    else
        directStep=solveLbfgsKKTsystem(Hess,KKTfactor,rhs,sizes);
    end


    directStep(sizes.nPrimal+1:end)=-directStep(sizes.nPrimal+1:end);


    function directStep=solveLbfgsKKTsystem(Hess,KKTfactor,rhs,sizes)







        import matlab.internal.math.nowarn.mldivide

        cm=Hess.currentMemory;

        if cm==0


            directStep=backsolveSys(KKTfactor,rhs);
        else

            nVar=sizes.nVar;
            qnMemory=Hess.qnMemory;


            U=zeros(sizes.nPrimal+sizes.mAll,2*qnMemory);
            V=zeros(sizes.nPrimal+sizes.mAll,2*qnMemory);


            U(1:nVar,1:2*cm)=[Hess.delta*Hess.S(:,1:cm),Hess.Y(:,1:cm)];
            V(:,1:2*cm)=backsolveSys(KKTfactor,U(:,1:2*cm));

            t1=V(:,1:2*cm)'*rhs;


            t2=(-Hess.M(1:2*cm,1:2*cm)+U(1:nVar,1:2*cm)'*V(1:nVar,1:2*cm))\t1;
            t3=backsolveSys(KKTfactor,rhs);
            directStep=t3-V(:,1:2*cm)*t2;
        end
