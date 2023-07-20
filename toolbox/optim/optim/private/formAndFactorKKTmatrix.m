function KKTfactor=formAndFactorKKTmatrix(KKTfactor,...
    Hess,barrierHess_s,JacTrans_ip,KKT_error,barrierParam,options,sizes)











    mIneq=sizes.mIneq;

    regParamHess=0.0;regParamCons=0.0;
    factorize=true;factorCount=0;
    while factorize
        KKTmatrix=formKKTmatrix(Hess,barrierHess_s,JacTrans_ip,regParamHess,...
        regParamCons,options,sizes);
        [KKTfactor,isSingular]=factorKKTmatrix(KKTmatrix,KKTfactor,options);
        factorCount=factorCount+1;
        if(isSingular)
            if(factorCount==1)


                regParamCons=min(1e-2*KKT_error,1e-8);
                if mIneq>0
                    regParamCons=min(regParamCons,barrierParam);
                end
            elseif(factorCount==2)



                regParamHess=1e-15;
            else


                factorize=false;
            end
        else
            factorize=false;
        end
    end


    function KKTmatrix=formKKTmatrix(Hess,barrierHess_s,JacTrans_ip,...
        regParamHess,regParamCons,options,sizes)


        nVar=sizes.nVar;mEq=sizes.mEq;mIneq=sizes.mIneq;
        delta_h=regParamCons;





        if~strcmpi(options.HessType,'lbfgs')
            Hess_ip=[Hess+spdiags(regParamHess*ones(nVar,1),0,nVar,nVar),sparse(nVar,mIneq)
            sparse(mIneq,nVar),spdiags(barrierHess_s,0,mIneq,mIneq)];
        else

            Hess_ip=spdiags([Hess.delta*ones(nVar,1);barrierHess_s],0,nVar+mIneq,nVar+mIneq);
        end

        KKTmatrix=[Hess_ip,JacTrans_ip
        sparse(mEq+mIneq,nVar+mIneq),spdiags([-delta_h*ones(mEq,1);zeros(mIneq,1)],0,mEq+mIneq,mEq+mIneq)];


        function[KKTfactor,isSingular]=factorKKTmatrix(KKTmatrix,KKTfactor,options)


            if strcmpi(options.LinearSystemSolver,'ldl-factorization')
                [KKTfactor.U,KKTfactor.D,KKTfactor.p,KKTfactor.S,...
                KKTfactor.numNegEig,kktRank]=ldl(KKTmatrix,options.PivotThreshold,'upper','vector');
                isSingular=kktRank<size(KKTmatrix,1);
            else
                error(message('optim:formAndFactorKKTmatrix:BadLinearSystemSolver'));
            end
