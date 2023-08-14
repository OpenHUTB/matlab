function[CompactAugMatrix,AugFactor]=formAndFactorAugMatrix(CompactAugMatrix,...
    AugFactor,JacTrans_ip,slacks,KKT_error,barrierParam,sizes,options)












    mIneq=sizes.mIneq;

    regParamCons=0.0;
    factorize=true;factorCount=0;
    while factorize
        CompactAugMatrix=formAugMatrix(CompactAugMatrix,JacTrans_ip,slacks,regParamCons,sizes);
        [AugFactor,isSingular]=factorAugMatrix(CompactAugMatrix,AugFactor,options);
        factorCount=factorCount+1;
        if(isSingular)
            if(factorCount==1)


                regParamCons=min(1e-2*KKT_error,1e-8);
                if mIneq>0
                    regParamCons=min(regParamCons,barrierParam);
                end
            else


                factorize=false;
            end
        else
            factorize=false;
        end
    end


    function CompactAugMatrix=formAugMatrix(CompactAugMatrix,JacTrans_ip,slacks,regParamCons,sizes)


        nVar=sizes.nVar;mEq=sizes.mEq;mIneq=sizes.mIneq;
        delta_h=regParamCons;



        CompactAugMatrix=...
        [speye(nVar),JacTrans_ip(1:nVar,:)
        sparse(mEq+mIneq,nVar),spdiags([-delta_h*ones(mEq,1);-slacks.^2],0,mEq+mIneq,mEq+mIneq)];


        function[AugFactor,isSingular]=factorAugMatrix(AugMatrix,AugFactor,options)


            if strcmpi(options.LinearSystemSolver,'ldl-factorization')
                [AugFactor.U,AugFactor.D,AugFactor.p,AugFactor.S,...
                ~,augRank]=ldl(AugMatrix,options.PivotThreshold,'upper','vector');
                isSingular=augRank<size(AugMatrix,1);
            else
                error(message('optim:formAndFactorAugMatrix:BadLinearSystemSolver'));
            end
