classdef EigenSolverUpdater<cgsimfill.internal.optimizer.StepUpdater




















    properties(SetAccess=private)

Jacobian
    end

    methods

        function obj=EigenSolverUpdater

            obj.Name='EigenSolver';
            obj.Description='Eigenvalue analysis based optimization scheme';
        end

        function reset(obj)

            obj.Cost=0;
            obj.Gradient=0;
            obj.Jacobian=[];
        end

        function leastSquaresGradients(obj,J,e)





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




            [b,converged]=solveEigen(obj,b,smoothingMatrix,previousStepper,previousValues);
        end

    end

    methods(Access=private)
        function[newb,converged]=solveEigen(obj,b,smoothingMatrix,previousStepper,previousValues)




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
            if~(improved||isFirst)



                obj.Cost=previousStepper.Cost;
                obj.Jacobian=previousStepper.Jacobian;
                obj.Gradient=previousStepper.Gradient;
                b=previousValues;
            end
            J=obj.Jacobian;
            g=obj.Gradient;

            if~isempty(smoothingMatrix)

                J=[J;smoothingMatrix];
            end

            J=[J;lambda*speye(n)];

            scale_f=1000;
            H=J'*J;
            Hw=full(H);
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

            step=-g/5;

            for jj=1:n_extract
                js=IX(jj);
                step(js)=EE(jj);
            end


            step=obj.LearningRate*step;
            if obj.HasConstraints

                step=projectBox(obj,b(:),step);
            end
            newb=b+step;
        end

    end

    methods(Static)

        function obj=loadobj(obj)

            obj.Name='EigenSolver';
            obj.Description='Eigenvalue analysis based optimization';
        end

    end


end


