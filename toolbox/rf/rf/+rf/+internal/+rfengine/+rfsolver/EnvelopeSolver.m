


classdef EnvelopeSolver<handle

    properties
Transform
Evaluator

Residue
AllowedResidueError

Parameters
Tones
Dae

Counter
    end

    methods

        function o=EnvelopeSolver(dae,tones,harmonics,params)
            if params.HbVerbose
                fprintf('non-linear DAE has %d states, including %d frequency-domain states\n',dae.NumStates,dae.NumFreqStates);
            end

            o.Dae=dae;
            o.Parameters=params;
            o.Tones=tones;
            o.Transform=rf.internal.rfengine.rfsolver.MappedFFT(harmonics);
            o.Evaluator=rf.internal.rfengine.rfsolver.EnvelopeEvaluator(dae,tones,o.Transform,...
            params.HbIntegrationMethod,...
            params.HbTestLinearizedJacobian);
            o.Counter.nIters=0;
            o.Counter.nSteps=0;
        end

        function[X,SavedStates,success]=TakeStep(o,U,X_prev,U_prev,SavedStates,h,integration_method,isSteadyState)%#ok<INUSL>
            o.fprintf('\nstep %d, step size %f\n',o.Counter.nSteps,h);

            MaxIters=o.Parameters.HbMaxIters;
            X0=X_prev;

            [X,success,iter]=o.newton(X0,MaxIters,X_prev,h,U,SavedStates,integration_method,isSteadyState);

            o.Counter.nIters=o.Counter.nIters+iter;
            o.Counter.nSteps=o.Counter.nSteps+1;

            SavedStates=o.Evaluator.SavedStates(:);
        end

        function n=NumStates(o)
            n=o.Evaluator.Dae.NumStates;
        end

        function success=evaluate(o,x,evaluateJacobian,varargin)
            success=true;
            o.Evaluator.evaluate(x,evaluateJacobian,varargin{:});

            o.Residue=o.Evaluator.Residue;

            if~allfinite(o.Residue)||norm(o.Residue)>1e10
                success=false;
                return;
            end

            o.AllowedResidueError=o.Parameters.AbsTol;


        end

        function[x,success,iter]=newton(o,x,MaxIters,varargin)
            success=false;
            o.fprintf('\tnorm(F,inf)\t\tnorm(delta,inf)\tlimited\tresidue\t delta \n');

            evaluateJacobian=true;
            o.evaluate(x,evaluateJacobian,varargin{:});

            for iter=1:MaxIters


                [delta,solved]=o.solve(o.Residue);
                if~solved
                    break
                end



                deltaConverged=o.checkDelta(x,delta);


                [x,isLimited]=o.update(x,delta);


                evaluateJacobian=mod(iter,o.Parameters.HbJacobianUpdatePeriod)==0;
                success=o.evaluate(x,evaluateJacobian,varargin{:});
                if~success
                    warning('EnvelopeSolver.newton.evaluate failed')
                    break
                end


                residueConverged=o.checkResidue;

                o.fprintf('%-2d\t%.2e\t\t%.2e\t\t%d\t\t%d\t\t%d\n',iter,norm(o.Residue,inf),...
                norm(delta,inf),isLimited,residueConverged,deltaConverged);

                success=residueConverged&&deltaConverged&&~isLimited;
                if success
                    break;
                end
            end


        end

        function[delta,success]=solve(o,residue)
            success=true;
            gmres_tol=0.1;
            maxiters=min(10,numel(residue));
            [delta,flag,relres,iter]=gmres(@HbGmresMultiply,residue(:),[],gmres_tol,maxiters,@HbGmresPrecondition,[],[],o.Evaluator);

            s=sprintf('%d outer, %d inner iterations; final tolerance %.2e\n',iter(1),iter(2),relres);
            if flag==0
                s=['GMRES converged in ',s];
            else
                s=['GMRES did not converged in ',s];






            end
            o.fprintf(s);


            delta=o.Evaluator.reshape(delta);
        end

        function[x,is_limited]=update(o,x,delta)%#ok<INUSL> % Perform voltage step limiting on the Newton delta

            x=x-delta;
            is_limited=false;
        end

        function converged=checkDelta(o,x,dx)%#ok
            if(o.Parameters.ErrorEstimationType==1)
                converged=norm(dx)<o.Parameters.RelTol*norm(o.Evaluator.MaxAbsX)+o.Parameters.AbsTol;
            else
                converged=all(abs(dx)<o.Parameters.RelTol*o.Evaluator.MaxAbsX+o.Parameters.AbsTol,'all');
            end


        end

        function converged=checkResidue(o)%#ok




            converged=true;
        end

        function fprintf(o,varargin)
            if o.Parameters.HbVerbose
                fprintf(varargin{:});
            end
        end

        function f=freqs(o)
            f=o.Transform.freqs(o.Tones);
        end





        function n=nSavedStates(o)
            n=numel(o.Evaluator.SavedStates);
        end

    end
end

function y=HbGmresMultiply(x,o)
    y=o.jacobian_multiply(x);
end

function y=HbGmresPrecondition(x,o)
    y=o.precondition(x);
end

function view(o,x)%#ok<DEFNU> %debugging function
    x(abs(x)<1e-10)=0;
    disp(o.Evaluator.reshape(x));
end
