function Hess=computeHessian(hessfcn,xCurrent,lambda_ip,delta_x,delta_gradLag,Hess,...
    funfcn,confcn,grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,iter,fscale,...
    sizes,options,varargin)












    switch options.HessType
    case 'user-supplied'


        if strcmpi(options.ScaleProblem,'obj-and-constr')

            lambda.eqnonlin=(fscale.cEq.*lambda_ip(sizes.nonlinEq_start:sizes.nonlinEq_end,1))/fscale.obj;
            lambda.ineqnonlin=(fscale.cIneq.*lambda_ip(sizes.nonlinIneq_start:end,1))/fscale.obj;
        else
            lambda.eqnonlin=lambda_ip(sizes.nonlinEq_start:sizes.nonlinEq_end,1);
            lambda.ineqnonlin=lambda_ip(sizes.nonlinIneq_start:end,1);
        end




        lambda.eqnonlin=-lambda.eqnonlin;


        Hess=feval(hessfcn,xCurrent,lambda,varargin{:});



        if strcmpi(options.ScaleProblem,'obj-and-constr')&&fscale.objIsScaled
            Hess=fscale.obj*Hess;
        end
    case 'bfgs'

        if iter==0
            Hess=eye(sizes.nVar);
        else
            HessDelta_x=Hess*delta_x;
            curvAlongDelta_x=delta_x'*HessDelta_x;
            delta_xDelta_gradLag=delta_x'*delta_gradLag;


            [delta_gradLag,delta_xDelta_gradLag]=dampingProcedure(delta_gradLag,delta_x,...
            HessDelta_x,delta_xDelta_gradLag,curvAlongDelta_x);


            if curvAlongDelta_x>eps&&delta_xDelta_gradLag>eps
                Hess=Hess-((HessDelta_x*HessDelta_x')/curvAlongDelta_x)+...
                ((delta_gradLag*delta_gradLag')/delta_xDelta_gradLag);
            end
        end
    case 'lbfgs'

        if iter==0
            hessMemory=options.HessMemory;

            Hess=struct('S',zeros(sizes.nVar,hessMemory),...
            'Y',zeros(sizes.nVar,hessMemory),...
            'd',zeros(hessMemory,1),...
            'delta',1.0,...
            'L',zeros(hessMemory),...
            'M',zeros(2*hessMemory),...
            'M_Lfactor',zeros(2*hessMemory),...
            'M_Ufactor',zeros(2*hessMemory),...
            'qnMemory',hessMemory,...
            'currentMemory',0);
        else
            HessDelta_x=hessTimesVector(Hess,delta_x,funfcn,confcn,xCurrent,...
            grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,...
            options,sizes,varargin{:});

            delta_xDelta_gradLag=delta_x'*delta_gradLag;
            curvAlongDelta_x=delta_x'*HessDelta_x;
            [delta_gradLag,delta_xDelta_gradLag]=dampingProcedure(delta_gradLag,delta_x,...
            HessDelta_x,delta_xDelta_gradLag,curvAlongDelta_x);



            if curvAlongDelta_x>eps&&delta_xDelta_gradLag>eps
                Hess=lbfgsUpdate(delta_x,delta_gradLag,Hess);
            end
        end
    otherwise
        error(message('optim:computeHessian:BadHessType'));
    end


