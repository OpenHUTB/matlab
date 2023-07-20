classdef SecondOrderUpdater<cgsimfill.internal.optimizer.StepUpdater


























    properties(SetAccess=private)

Jacobian

Subspace

        TrustRegionRadius=1;

        NormalizedStepDirection=1;

        QuadraticObjective=1;
    end

    methods

        function obj=SecondOrderUpdater

            obj.Name='SecondOrder';
            obj.Description='Second order';

            obj.LearningRate=obj.TrustRegionRadius;
        end

        function reset(obj)

            obj.Cost=0;
            obj.Gradient=0;
            obj.Jacobian=[];
        end

        function leastSquaresGradients(obj,J,e)




            if iscell(J)

                J=[J{:}];
            end


            if obj.needsReduction(J)
                [J,g]=obj.reduce(J,e);
            else

                g=-J'*e;
            end

            obj.Gradient=g;

            obj.Jacobian=J;
            obj.Cost=e'*e;

        end

        function accumulate(obj,nextObj,weight)




            obj.Gradient=obj.Gradient+weight*nextObj.Gradient;

            obj.Jacobian=[obj.Jacobian;sqrt(weight)*nextObj.Jacobian];

            obj.Cost=obj.Cost+weight*nextObj.Cost;

            if obj.needsReduction(obj.Jacobian)

                obj.Jacobian=obj.squareRDecomposition(obj.Jacobian);
            end
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

            previousCost=previousStepper.Cost;
            if isempty(previousStepper.Jacobian)

                previousCost=obj.Cost;
            end
            currentCost=obj.Cost;
            improved=currentCost<previousCost;
            isFirst=isempty(previousStepper.Jacobian);
            previousG=previousStepper.Gradient;
            if isFirst
                previousG=obj.Gradient;
            end
            if(improved||isFirst)&&...
                (isfinite(obj.Cost)&&all(isfinite(obj.Gradient))&&all(isfinite(obj.Jacobian),'all'))


                obj.Subspace=[];
            else
                if isFirst
                    error('mbc:cgsimfill:optimizer:NonfiniteInitialValue',...
                    'Initial values or initial gradients are not finite.')
                end



                obj.Cost=previousStepper.Cost;
                obj.Jacobian=previousStepper.Jacobian;
                obj.Gradient=previousStepper.Gradient;
                b=previousValues;
            end
            J=obj.Jacobian;
            g=obj.Gradient;

            if~isempty(smoothingMatrix)

                J=[J;smoothingMatrix];
                g=g+2*smoothingMatrix'*sb;
            end

            J=[J;lambda*speye(n)];


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
                if currentCost>1e10||~allfinite(g)||~allfinite(J)||~isfinite(currentCost)


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
            if size(J,2)>3000

                precondBandWidth=0;
            else

                precondBandWidth=Inf;
            end

            [step,snod,qp,~,~,Z]=trdog(b,g,J,D,delta,dv,...
            @atamult,@aprecon,precondBandWidth,pcgtol,maxPCGIter,theta,...
            lb,ub,obj.Subspace,[],'jacobprecon');
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

            obj.Name='SecondOrder';
            obj.Description='Second order';

        end

    end


end




