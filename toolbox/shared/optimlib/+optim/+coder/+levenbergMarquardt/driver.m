function[x,resnorm,fCurrent,exitflag,output,lambda,jacobian]=driver(fun,x0,lb,ub,options)































%#codegen

    eml_allow_mx_inputs;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fun,x0,lb,ub,options);





    validateattributes(lb,{'double'},{'column'});
    validateattributes(ub,{'double'},{'column'});

    validateattributes(options,{'struct'},{'scalar'});

    n=coder.internal.indexInt(numel(x0));
    funcCount=coder.internal.indexInt(1);
    tolActive=double(0);
    indActive=false(n,1);
    projSteepestDescentInfNorm=double(0);

    if nargout>=6
        lambda.lower=coder.nullcopy(zeros(n,1));
        lambda.upper=coder.nullcopy(zeros(n,1));
    end

    gradf=coder.nullcopy(zeros(n,1));
    xp=zeros(size(x0));
    x=zeros(size(x0));
    dx=coder.internal.inf(size(x0));
    funDiff=coder.internal.inf;

    scaleFactors=ones(n,1);


    epsDouble=coder.const(eps('double'));

    iter=coder.internal.indexInt(0);


    if options.MaxFunctionEvaluations==-1
        options.MaxFunctionEvaluations=double(200*n);
    end
    if options.FiniteDifferenceStepSize==-1
        if strcmpi(options.FiniteDifferenceType,'forward')
            options.FiniteDifferenceStepSize=sqrt(eps);
        elseif strcmpi(options.FiniteDifferenceType,'central')
            options.FiniteDifferenceStepSize=eps^(1/3);
        end
    end
    if isempty(options.TypicalX)

        TypicalX=ones(n,1,'double');
    else
        TypicalX=options.TypicalX;
    end

    if~isempty(lb)&&~isempty(ub)
        minWidth=min(ub-lb);
    else
        minWidth=coder.internal.inf;
    end

    hasLB=coder.nullcopy(false(n,1));
    hasUB=coder.nullcopy(false(n,1));
    [hasLB,hasUB,hasFiniteBounds]=optim.coder.utils.hasFiniteBounds(n,hasLB,hasUB,lb,ub,options);


    if~hasFiniteBounds||minWidth<0
        x=x0;
    else
        x=optim.coder.levenbergMarquardt.projectBox(x,x0,lb,ub,hasLB,hasUB);
        if norm(x(:)-x0(:),'inf')>0
            coder.internal.warning('optimlib_codegen:common:InfeasibleX0');
        end
    end

    m_temp=0;
    if nargout(fun)==1||~options.SpecifyObjectiveGradient





        f_temp=fun(x);
        m_temp=numel(f_temp);
        jacobian=coder.nullcopy(zeros(m_temp,n));
    else




        [f_temp,jac_temp]=fun(x);
        coder.internal.assert(~isa(jac_temp,'single'),'optimlib_codegen:common:ObjectiveMustOutputDouble');
        coder.internal.assert(isreal(jac_temp),'optimlib:commonMsgs:ComplexGradient');
        coder.internal.assert(~issparse(jac_temp),'optimlib_codegen:common:InvalidSparseObjective');
        m_temp=numel(f_temp);
        jacobian=coder.nullcopy(zeros(m_temp,n));
        jacobian=jac_temp;
    end




    coder.internal.assert(~isa(f_temp,'single'),'optimlib_codegen:common:ObjectiveMustOutputDouble');
    coder.internal.assert(isreal(f_temp),'optimlib_codegen:common:ObjectiveMustOutputReal');
    coder.internal.assert(~issparse(f_temp),'optimlib_codegen:common:InvalidSparseObjective');

    m=coder.internal.indexInt(m_temp);
    s_temp=0;
    t_temp=0;
    [s_temp,t_temp]=size(f_temp);
    s=coder.internal.indexInt(s_temp);
    t=coder.internal.indexInt(t_temp);
    fCurrent=coder.nullcopy(zeros(s,t,'double'));
    fNew=coder.nullcopy(zeros(s,t,'double'));




    for i=1:m
        fCurrent(i)=f_temp(i);
    end

    augJacobian=coder.nullcopy(zeros(m+n,n));
    rhs=coder.nullcopy(zeros(m+n,1));




    augJacobian=coder.internal.lapack.xlacpy('A',m,n,jacobian,1,m,augJacobian,1,m+n);





    resnorm=coder.internal.blas.xdot(m,fCurrent,1,1,fCurrent,1,1);


    [evalOK,fCurrent]=optim.coder.validate.checkFinite(fCurrent,m,coder.internal.indexInt(1));
    coder.internal.assert(evalOK,'optimlib_codegen:common:NonFiniteInitialObjective');

    intZero=coder.internal.indexInt(0);
    FiniteDifferences=optim.coder.utils.FiniteDifferences.factoryConstruct(...
    [],@(x)deal(zeros(0,1),reshape(fun(x),[],1)),n,intZero,m,lb,ub,options);
    finiteDifferenceRunTimeOptions=struct('TypicalX',TypicalX,'FiniteDifferenceStepSize',...
    options.FiniteDifferenceStepSize*ones(n,1));

    if~options.SpecifyObjectiveGradient||nargout(fun)==1
        [augJacobian,fCurrent,funcCount,~,FiniteDifferences]=optim.coder.levenbergMarquardt.jacobianFiniteDifference(...
        augJacobian,fCurrent,funcCount,x,lb,ub,options,TypicalX,FiniteDifferences,finiteDifferenceRunTimeOptions);
    end

    gamma=options.InitDamping;









    sqrtGamma=sqrt(gamma);
    if strcmpi(options.ScaleProblem,'jacobian')

        for i=1:n

            augJacobian=coder.internal.blas.xcopy(n,0,1,0,augJacobian,(m+n)*i-n+1,1);



            scaleFactors(i)=coder.internal.blas.xnrm2(m,augJacobian,(m+n)*(i-1)+1,1);
            augJacobian(m+i,i)=sqrtGamma*scaleFactors(i);
        end
    else






        for i=1:n

            augJacobian=coder.internal.blas.xcopy(n,0,1,0,augJacobian,(m+n)*i-n+1,1);
            augJacobian(m+i,i)=sqrtGamma;
        end
    end

    jacobian=coder.internal.lapack.xlacpy('A',m,n,augJacobian,1,m+n,jacobian,1,m);

    [evalOK,augJacobian]=optim.coder.validate.checkFinite(augJacobian,m+n,n);
    coder.internal.assert(evalOK,'optimlib_codegen:common:NonFiniteInitialJacobian');




    gradf=coder.internal.blas.xgemv('T',m,n,1,jacobian,1,m,fCurrent,1,1,0,gradf,1,1);


    [~,projSteepestDescentInfNorm]=optim.coder.levenbergMarquardt.projectBox(x,-gradf,lb,ub,hasLB,hasUB);


    [firstOrderOpt,projSteepestDescentInfNorm]...
    =computeFirstOrderOpt(x,gradf,lb,ub,hasFiniteBounds,hasLB,hasUB,projSteepestDescentInfNorm);
    relFactor=max(firstOrderOpt,1.0);

    if strcmpi(options.Display,'testing')
        fprintf('                                        First-Order                    Norm of \n');
        fprintf(' Iteration  Func-count    Residual       optimality      Lambda           step\n');
        fprintf('   %3d       %5d   %13.6g    %12.3g %12.6g\n',...
        iter,funcCount,resnorm,firstOrderOpt,gamma);
    end

    stepSuccessful=true;

    if minWidth<0
        exitflag=coder.const(optim.coder.SolutionState('Infeasible'));
    else
        exitflag=optim.coder.levenbergMarquardt.checkStoppingCriteria(...
        options,gradf,relFactor,funDiff,x,dx,lb,ub,funcCount,stepSuccessful,...
        iter,projSteepestDescentInfNorm,hasFiniteBounds);
    end

    while exitflag==coder.const(optim.coder.SolutionState('StartContinue'))




        rhs=coder.internal.blas.xcopy(m,-fCurrent,1,1,rhs,1,1);
        rhs=coder.internal.blas.xcopy(n,0,1,0,rhs,m+1,1);


        if hasFiniteBounds
            [~,projSteepestDescentInfNorm]=optim.coder.levenbergMarquardt.projectBox(...
            x,-gradf/(1+gamma)./max(epsDouble,scaleFactors.^2),lb,ub,hasLB,hasUB);
            tolActive=min(projSteepestDescentInfNorm,minWidth/2);
            for i=1:n

                if hasLB(i)
                    indActive(i)=(x(i)-lb(i)<=tolActive&&gradf(i)>0);
                end
                if hasUB(i)
                    indActive(i)=indActive(i)||(ub(i)-x(i)<=tolActive&&gradf(i)<0);
                end





                if indActive(i)
                    augJacobian=coder.internal.blas.xcopy(m,0,1,0,augJacobian,(m+n)*(i-1)+1,1);
                end

            end
        end








        [augJacobian,rhs,dx]=optim.coder.levenbergMarquardt.linearLeastSquares(...
        augJacobian,rhs,dx,m+n,n);

        if hasFiniteBounds




            for i=1:n
                if indActive(i)
                    dx(i)=-gradf(i)/(1+gamma)/max(epsDouble,scaleFactors(i)^2);
                end
            end

            xp=optim.coder.levenbergMarquardt.projectBox(zeros(0,1),x+dx,lb,ub,hasLB,hasUB);
        else
            xp=x+dx;
        end

        if nargout(fun)==1||~options.SpecifyObjectiveGradient
            f_temp=fun(xp);
        else
            [f_temp,augJacobian(1:m,:)]=fun(xp);
        end
        for i=1:m
            fNew(i)=f_temp(i);
        end




        resnormNew=coder.internal.blas.xdot(m,fNew,1,1,fNew,1,1);


        [evalOK,fNew]=optim.coder.validate.checkFinite(fNew,m,coder.internal.indexInt(1));

        funcCount=funcCount+1;
        if resnormNew<resnorm&&evalOK
            iter=iter+1;
            funDiff=abs(resnormNew-resnorm)/resnorm;
            fCurrent=fNew;



            resnorm=resnormNew;

            if nargout(fun)==1||~options.SpecifyObjectiveGradient




                [augJacobian,fCurrent,funcCount,evalOK]=optim.coder.levenbergMarquardt.jacobianFiniteDifference(...
                augJacobian,fCurrent,funcCount,xp,lb,ub,options,TypicalX,...
                FiniteDifferences,finiteDifferenceRunTimeOptions);



                jacobian=coder.internal.lapack.xlacpy('A',m,n,augJacobian,1,m+n,jacobian,1,m);
            else



                jacobian=coder.internal.lapack.xlacpy('A',m,n,augJacobian,1,m+n,jacobian,1,m);
                [evalOK,jacobian]=optim.coder.validate.checkFinite(jacobian,m,n);
            end
            if evalOK
                x(:)=xp(:);
                if stepSuccessful
                    gamma=gamma*0.1;
                end
                stepSuccessful=true;
            else

                exitflag=coder.const(optim.coder.SolutionState('ObjectiveLimitReached'));



                jacobian=coder.internal.blas.xcopy(m*n,coder.internal.nan,1,0,jacobian,1,1);

                if strcmpi(options.Display,'testing')
                    fprintf('   %3d       %5d   %13.6g    %12.3g %12.6g   %12.6g\n',...
                    iter,funcCount,resnormNew,coder.internal.nan,gamma,norm(dx(:)));
                end
                break;
            end
        else
            gamma=gamma*10;
            stepSuccessful=false;



            augJacobian=coder.internal.lapack.xlacpy('A',m,n,jacobian,1,m,augJacobian,1,m+n);
        end








        sqrtGamma=sqrt(gamma);
        if strcmpi(options.ScaleProblem,'jacobian')

            for i=1:n

                augJacobian=coder.internal.blas.xcopy(n,0,1,0,augJacobian,(m+n)*i-n+1,1);



                scaleFactors(i)=coder.internal.blas.xnrm2(m,augJacobian,(m+n)*(i-1)+1,1);
                augJacobian(m+i,i)=sqrtGamma*scaleFactors(i);

            end
        else






            for i=1:n

                augJacobian=coder.internal.blas.xcopy(n,0,1,0,augJacobian,(m+n)*i-n+1,1);
                augJacobian(m+i,i)=sqrtGamma;
            end
        end





        gradf=coder.internal.blas.xgemv('T',m,n,1,jacobian,1,m,fCurrent,1,1,0,gradf,1,1);


        [~,projSteepestDescentInfNorm]=optim.coder.levenbergMarquardt.projectBox(x,-gradf,lb,ub,hasLB,hasUB);

        if strcmpi(options.Display,'testing')&&stepSuccessful
            [firstOrderOpt,projSteepestDescentInfNorm]...
            =computeFirstOrderOpt(x,gradf,lb,ub,hasFiniteBounds,hasLB,hasUB,projSteepestDescentInfNorm);
            fprintf('   %3d       %5d   %13.6g    %12.3g %12.6g   %12.6g\n',...
            iter,funcCount,resnormNew,firstOrderOpt,gamma,norm(dx(:)));
        end
        [exitflag,iter]=optim.coder.levenbergMarquardt.checkStoppingCriteria(...
        options,gradf,relFactor,funDiff,x,dx,lb,ub,funcCount,stepSuccessful,...
        iter,projSteepestDescentInfNorm,hasFiniteBounds);
        if exitflag~=coder.const(optim.coder.SolutionState('StartContinue'))
            break;
        end
    end

    exitflag=double(exitflag);

    if nargout>=5


        if~strcmpi(options.Display,'testing')
            [firstOrderOpt,projSteepestDescentInfNorm]...
            =computeFirstOrderOpt(x,gradf,lb,ub,hasFiniteBounds,hasLB,hasUB,projSteepestDescentInfNorm);
        end
        output=struct('iterations',double(iter),...
        'funcCount',double(funcCount),...
        'stepsize',norm(dx(:)),...
        'cgiterations',[],...
        'firstorderopt',firstOrderOpt,...
        'algorithm','levenberg-marquardt',...
        'message','');
    end

    if nargout>=6
        lambda.lower=zeros(n,1);
        lambda.upper=zeros(n,1);

        if hasFiniteBounds
            [~,projSteepestDescentInfNorm]=optim.coder.levenbergMarquardt.projectBox(...
            x,-gradf/(1+gamma)./max(epsDouble,scaleFactors.^2),lb,ub,hasLB,hasUB);
            tolActive=min(projSteepestDescentInfNorm,minWidth/2);
            for i=1:n
                if hasLB(i)
                    if x(i)-lb(i)<=tolActive&&gradf(i)>0
                        lambda.lower(i)=2*gradf(i);
                    end
                end
                if hasUB(i)
                    if ub(i)-x(i)<=tolActive&&gradf(i)<0
                        lambda.upper(i)=-2*gradf(i);
                    end
                end
            end
        end
    end

end

function[firstOrderOpt,projSteepestDescentInfNorm]=...
    computeFirstOrderOpt(x,gradf,lb,ub,hasFiniteBounds,hasLB,hasUB,projSteepestDescentInfNorm)
    if hasFiniteBounds
        a=projSteepestDescentInfNorm;
        b=norm(gradf,'inf');


        if abs(a-b)<eps('double')*max(a,b)||b==0
            firstOrderOpt=a;
        else
            firstOrderOpt=a^2/b;
        end
    else
        firstOrderOpt=norm(gradf,'inf');
    end
end

