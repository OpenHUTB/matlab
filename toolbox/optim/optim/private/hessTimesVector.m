function[w,numFunEvals]=hessTimesVector(Hess,vec,funfcn,confcn,xCurrent,...
    grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin)












    switch options.HessType
    case{'user-supplied','bfgs'}
        w=Hess*vec;
        numFunEvals=0;
    case 'lbfgs'
        w=lbfgsMatrixTimesVector(Hess,vec);
        numFunEvals=0;
    case 'fin-diff-grads'
        [w,numFunEvals]=finDiffInGrads(vec,funfcn,confcn,xCurrent,grad,...
        JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin{:});
    case 'hessmult'


        if strcmpi(options.ScaleProblem,'obj-and-constr')

            lambda.eqnonlin=(fscale.cEq.*lambda_ip(sizes.nonlinEq_start:sizes.nonlinEq_end,1))/fscale.obj;
            lambda.ineqnonlin=(fscale.cIneq.*lambda_ip(sizes.nonlinIneq_start:end,1))/fscale.obj;
        else
            lambda.eqnonlin=lambda_ip(sizes.nonlinEq_start:sizes.nonlinEq_end);
            lambda.ineqnonlin=lambda_ip(sizes.nonlinIneq_start:end);
        end
        w=options.HessMult(xCurrent,lambda,vec,varargin{:});
        numFunEvals=1;



        if strcmpi(options.ScaleProblem,'obj-and-constr')&&fscale.objIsScaled
            w=fscale.obj*w;
        end
    end


    function w=lbfgsMatrixTimesVector(Hess,vec)




        import matlab.internal.math.nowarn.mldivide

        cm=Hess.currentMemory;

        w=Hess.delta*vec;


        if cm>0
            t1=[Hess.delta*Hess.S(:,1:cm)'*vec;Hess.Y(:,1:cm)'*vec];
            t2=Hess.M_Lfactor(1:2*cm,1:2*cm)\t1;
            t3=Hess.M_Ufactor(1:2*cm,1:2*cm)\t2;
            w=w-[Hess.delta*Hess.S(:,1:cm),Hess.Y(:,1:cm)]*t3;
        end


        function[w,numFunEvals]=finDiffInGrads(vec,funfcn,confcn,xCurrent,grad,...
            JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin)



            nonlinEq_start=sizes.nonlinEq_start;
            nonlinEq_end=sizes.nonlinEq_end;
            nonlinIneq_start=sizes.nonlinIneq_start;
            grad_plus=zeros(sizes.nVar,1);
            JacCineqTrans_plus=zeros(sizes.nVar,sizes.mNonlinIneq);
            JacCeqTrans_plus=zeros(sizes.nVar,sizes.mNonlinEq);


            alpha=1e-7*(1.0+norm(xCurrent));
            if strcmpi(options.AlwaysHonorConstraints,'bounds')||strcmpi(options.AlwaysHonorConstraints,'bounds-ineqs')






                idx=(xIndices.finiteLb|xIndices.finiteUb)&xCurrent>=lb&xCurrent<=ub;
                alpha=directionalFinDiffInsideBnds(xCurrent(idx),alpha,vec(idx),lb(idx),...
                ub(idx),options.DiffMinChange);
            end

            x_plus=xCurrent+alpha*vec;

            if strcmp(funfcn{1},'fungrad')
                [~,grad_plus(:)]=feval(funfcn{3},reshape(x_plus,sizes.xShape),varargin{:});
            elseif strcmp(funfcn{1},'fun_then_grad')
                grad_plus(:)=feval(funfcn{4},reshape(x_plus,sizes.xShape),varargin{:});
            end
            if strcmp(confcn{1},'fungrad')
                [~,~,JacCineqTrans_plus(:),JacCeqTrans_plus(:)]=...
                feval(confcn{3},reshape(x_plus,sizes.xShape),varargin{:});
            elseif strcmp(funfcn{1},'fun_then_grad')
                [JacCineqTrans_plus(:),JacCeqTrans_plus(:)]=...
                feval(confcn{4},reshape(x_plus,sizes.xShape),varargin{:});
            end
            if strcmpi(options.ScaleProblem,'obj-and-constr')
                grad_plus=fscale.obj*grad_plus;
                JacCeqTrans_plus=JacCeqTrans_plus*spdiags(fscale.cEq,0,sizes.mNonlinEq,sizes.mNonlinEq);
                JacCineqTrans_plus=JacCineqTrans_plus*spdiags(fscale.cIneq,0,sizes.mNonlinIneq,sizes.mNonlinIneq);
            end
            numFunEvals=1;

            JacCineqTrans_plus=-JacCineqTrans_plus;

            w=(grad_plus-JacCeqTrans_plus*lambda_ip(nonlinEq_start:nonlinEq_end,1)...
            -JacCineqTrans_plus*lambda_ip(nonlinIneq_start:end,1)...
            -(grad-JacCeqTrans*lambda_ip(nonlinEq_start:nonlinEq_end,1)-...
            JacCineqTrans*lambda_ip(nonlinIneq_start:end,1)))/alpha;


            function alpha=directionalFinDiffInsideBnds(xC,alpha,vec,lb,ub,DiffMinChange)




                if any(xC+alpha*vec<lb|xC+alpha*vec>ub)
                    if any(xC-alpha*vec<lb|xC-alpha*vec>ub)





                        neg_idx=vec<-eps;
                        pos_idx=vec>eps;
                        alphaPlus=min([(ub(pos_idx)-xC(pos_idx))./vec(pos_idx);
                        (lb(neg_idx)-xC(neg_idx))./vec(neg_idx)]);

                        alphaMinus=min([(xC(neg_idx)-ub(neg_idx))./vec(neg_idx);
                        (xC(pos_idx)-lb(pos_idx))./vec(pos_idx)]);
                        [alpha,idx]=max([alphaMinus,alphaPlus]);
                        alpha=((-1)^idx)*alpha;



                        if abs(alpha)*norm(vec)<DiffMinChange
                            mexcptn=MException('optim:hessTimesVector:StepSizeTooSmall',...
                            getString(message('optim:hessTimesVector:StepSizeTooSmall')));
                            throwAsCaller(mexcptn);
                        end
                    else

                        alpha=-alpha;
                    end
                end
