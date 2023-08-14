classdef TrustRegionReflective<cgsimfill.internal.optimizer.StepUpdater




















    properties(SetAccess=private)

        Hessian=sparse(0)

Subspace

        TrustRegionRadius=1;

        NormalizedStepDirection=1;

        QuadraticObjective=1;
    end

    methods

        function obj=TrustRegionReflective

            obj.Name='TrustRegionReflective';
            obj.Description='Trust-region reflective';

            obj.LearningRate=obj.TrustRegionRadius;
        end

        function reset(obj)

            obj.Cost=0;
            obj.Gradient=0;
            obj.Hessian=sparse(0);
        end

        function leastSquaresGradients(obj,cost,g,H)




            obj.Gradient=g;

            obj.Hessian=H;
            obj.Cost=cost;

        end

        function accumulate(obj,nextObj,weight)




            obj.Gradient=obj.Gradient+weight*nextObj.Gradient;

            obj.Hessian=obj.Hessian+weight*nextObj.Hessian;

            obj.Cost=obj.Cost+weight*nextObj.Cost;

        end

        function[b,converged]=solve(obj,b,smoothingMatrix,previousStepper,previousValues)




            [b,converged]=solveTrust(obj,b,smoothingMatrix,previousStepper,previousValues);
        end

        function initialize(obj,LS)


            if LS.StepSize~=obj(1).LearningRate


                [obj.TrustRegionRadius]=deal(LS.StepSize);
            end
            initialize@cgsimfill.internal.optimizer.StepUpdater(obj,LS);
        end

        function clearMemory(obj)



            obj.TrustRegionRadius=obj.LearningRate;
        end

    end

    methods(Access=private)
        function[newb,converged]=solveTrust(obj,b,smoothingMatrix,previousStepper,previousValues)




            converged=false;
            n=length(b);
            if~isempty(smoothingMatrix)

                sb=smoothingMatrix*b(:);
                obj.Cost=obj.Cost+sb'*sb;
            end
            lambda=1e-6;

            obj.Cost=obj.Cost+lambda^2*(b'*b);

            isFirst=isequal(previousStepper.Hessian,sparse(0));

            previousCost=previousStepper.Cost;
            if isFirst

                previousCost=obj.Cost;
            end
            currentCost=obj.Cost;
            improved=currentCost<previousCost;
            previousG=previousStepper.Gradient;
            if isFirst
                previousG=obj.Gradient;
            end
            if(improved||isFirst)&&...
                (isfinite(obj.Cost)&&obj.Cost<1e10&&allfinite(obj.Gradient)&&allfinite(obj.Hessian))&&normest(obj.Hessian)<1e10


                obj.Subspace=[];
            else
                if isFirst
                    error('mbc:cgsimfill:optimizer:NonfiniteInitialValue',...
                    'Initial values or initial gradients are not finite.')
                end



                obj.Cost=previousStepper.Cost;
                obj.Hessian=previousStepper.Hessian;
                obj.Gradient=previousStepper.Gradient;
                b=previousValues;
            end
            H=obj.Hessian;
            g=obj.Gradient;

            if~isempty(smoothingMatrix)

                H=H+2*(smoothingMatrix'*smoothingMatrix);
                g=g+2*(smoothingMatrix'*sb);
            end

            H=H+lambda^2*speye(n);




            ws=warning('off','MATLAB:singularMatrix');
            restoreWarn=onCleanup(@()warning(ws));
            dNewton=[];
            if(improved||isFirst)&&size(H,2)<=10000



                nvars=size(H,1);
                lambda=eigs(H,max(min(ceil(nvars/10),100),min(nvars,5)));

                if min(lambda)<0


                    dNewton=eigenDirection(H,g);
                    if norm(dNewton,inf)>1e10||~allfinite(dNewton)
                        dNewton=[];
                    end
                end
            end


            if isempty(obj.Bounds)
                lb=-Inf(n,1);
                ub=Inf(n,1);
            else
                lb=obj.Bounds(:,1);
                ub=obj.Bounds(:,2);
            end


            [v,dv]=definev(previousG,b,lb,ub);
            gopt=v.*previousG;
            optnrm=norm(gopt,inf);


            delta=obj.TrustRegionRadius;
            if~isFirst


                nrmsx=norm(obj.NormalizedStepDirection);
                if currentCost>1e10||~allfinite(g)||~allfinite(H)||~isfinite(currentCost)


                    delta=min(nrmsx/20,delta/20);
                else


                    aug=.5*obj.NormalizedStepDirection'*((dv.*abs(previousG)).*obj.NormalizedStepDirection);

                    ratio=(0.5*(currentCost-previousCost)+aug)/obj.QuadraticObjective;
                    if(ratio>=0.75)&&(nrmsx>=.9*delta)


                        delta=min(2*delta,1e6);
                    elseif ratio<=0.25


                        delta=min(nrmsx/4,delta/4);
                    end

                end

                converged=delta<1e-6;

            end


            [v,dv]=definev(g,b,lb,ub);
            dd=abs(v);
            D=sparse(1:n,1:n,full(sqrt(dd)));
            theta=max(.95,1-optnrm);



            maxPCGIter=max(1,n/2);
            pcgtol=0.1;




            if size(H,2)>3000

                precondBandWidth=0;
            else

                precondBandWidth=Inf;
            end


            [step,snod,qp,~,~,Z]=trdog(b,g(:,1),H,D,delta,dv,...
            @hessMult_optimInternal,@hprecon,precondBandWidth,pcgtol,maxPCGIter,...
            theta,lb,ub,obj.Subspace,dNewton,'hessprecon');

            obj.QuadraticObjective=qp;
            obj.NormalizedStepDirection=snod;
            if improved||isFirst



                obj.Subspace=Z;
            end


            newb=b+step;


            [~,newb]=perturbTrustRegionReflective(newb,lb,ub);


            obj.TrustRegionRadius=delta;

        end

    end

    methods(Static)
        function obj=loadobj(obj)
            obj.CalculateHessian=true;
        end
    end

end





function[dEig,minLambda]=eigenDirection(H,g)
    Hw=full(H);
    scale_f=1000;
    [nx,~]=size(Hw);

    Aii_order=diag(Hw);
    [Aii_sort,IX]=sort(Aii_order,'descend');
    Aii_max=Aii_sort(1);
    Index=find(Aii_sort<Aii_max/scale_f);
    if isempty(Index)
        n_extract=nx;
    else
        n_extract=max(Index(1)-1,1);
    end
    A_sort=Hw(IX,IX);
    B_sort=-g(IX);
    AA_sort=A_sort(1:n_extract,1:n_extract);
    BB_sort=B_sort(1:n_extract);


    [v,d]=eig(AA_sort,'nobalance');
    eig_v=diag(d);
    minLambda=min(eig_v);
    [eig_v_sort,IX_eig]=sort(eig_v,'descend');
    eig_max=eig_v_sort(1);
    eig_scale=n_extract*40;
    eig_scale=min(eig_scale,1500);
    eig_scale=max(eig_scale,400);


    v_sort=v(:,IX_eig);
    Index_eig=find(eig_v_sort<eig_max/eig_scale);

    if isempty(Index_eig)
        dd_inv=diag(1./eig_v_sort);
        CC=v_sort*dd_inv;
        DD=CC*v_sort';
        EE=DD*BB_sort;
    else
        ns=Index_eig(1)-1;
        dd_inv=zeros(n_extract,n_extract);
        dd_inv(1:n_extract+1:ns+(ns-1)*n_extract)=1./eig_v_sort(1:ns);

        eig_ns=eig_v_sort(ns);
        dd_inv(ns+1+ns*n_extract:n_extract+1:end)=1./(eig_v_sort(ns+1:end)+eig_ns);

        eig_B=zeros(n_extract,n_extract);
        eig_B(ns+1+ns*n_extract:n_extract+1:end)=eig_ns;


        CC_1=v_sort*eig_B;
        DD_1=CC_1*v_sort';
        EE_1=DD_1*BB_sort;
        BB_sort_new=BB_sort+EE_1;

        CC=v_sort*dd_inv;
        DD=CC*v_sort';
        EE=DD*BB_sort_new;

        iteNum=max(n_extract,40);
        iteNum=min(iteNum,20);
        for k_it=1:iteNum
            EE_1=DD_1*EE;
            BB_sort_new=BB_sort+EE_1;
            EE=DD*BB_sort_new;
        end
    end

    dEig=-g/5;

    for jj=1:n_extract
        js=IX(jj);
        dEig(js)=EE(jj);
    end
end