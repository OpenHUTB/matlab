classdef OP<handle




    properties
Circuit
Parameters
Evaluator
X

Residue
Jacobian
L
U
P

Counter

AllowedDeltaError
AllowedResidueError

Flambda
        Lambda=0
    end

    methods
        function self=OP(ckt)
            if nargin>0
                self.Circuit=ckt;
                self.Circuit.OP=self;
            end
        end

        function[result,success]=Execute(self,params)
            self.Parameters=params;
            beta=self.Parameters.OpConductanceToGround;

            if isa(self.Circuit,'rf.internal.rfengine.Circuit')

                computeGlobalConnectivity(self.Circuit,beta)
                self.Evaluator=rf.internal.rfengine.analyses.circuitEvaluator(self.Circuit,self);
            else
                error('unknown type')
            end
            self.Evaluator.EvaluateCharge=false;

            self.fprintf('Operating point analysis begins...\n');

            B=self.Circuit.NumBranches;
            N=self.Circuit.NumNodes;
            initial_guess=zeros(B+N-1,1);

            [self.X,success,self.Counter.NewtonIters]=...
            sourceStepNewton2(self,initial_guess,beta);
            result=[];
            if success
                self.fprintf(...
                'Operating point analysis converged (Newton iterations: %d)\n\n',...
                self.Counter.NewtonIters);
            else
                error('Operating point analysis did not converge');
            end
        end

        function out=V(self,nodeName)
            out=self.X(self.Circuit.NumBranches+1:end,:);
            if nargin>1
                validateattributes(nodeName,{'char','string'},...
                {'nonempty','scalartext'},'','nodeName')
                i=self.Circuit.NodeMap(nodeName)-1;
                out=out(i,:);
            end
        end

        function out=I(self,branchName)
            out=self.X(1:self.Circuit.NumBranches,:);
            if nargin>1
                validateattributes(branchName,{'char','string'},...
                {'nonempty','scalartext'},'','branchName')
                i=strcmpi(self.Circuit.VariableNames,branchName);
                out=out(i,:);
            end
        end

        function evaluate(self,x,evaluateJacobian,beta)

            time=0;
            timeDomainEvaluate(self.Evaluator,x,time,evaluateJacobian,beta)

            freq=0;
            freqDomainEvaluate(self.Evaluator,x,freq,evaluateJacobian)


            self.Residue=[self.Evaluator.Fiv-self.Lambda*self.Evaluator.Uiv;
            self.Evaluator.Fk];



            self.AllowedResidueError=...
            abs(self.Residue)*self.Parameters.RelTol...
            +self.Parameters.AbsTol;

            if evaluateJacobian
                self.Jacobian=self.Evaluator.G+real(self.Evaluator.G_freq);
                [self.L,self.U,self.P]=lu(self.Jacobian);
            end


        end

        function[x,success,iters]=sourceStepNewton2(self,x0,beta)























            self.Lambda=1;
            N=self.Circuit.NumNodes;
            evaluateJacobian=true;
            evaluate(self,x0,evaluateJacobian,beta);
            dXdLambda=-self.solve(self.Residue);
            x=x0+dXdLambda;

            prevLambda=0;
            dLambda=1;
            iters=0;
            deltaConverged=false;
            while true
                success=false;

                if 1.1*dLambda>=1-prevLambda
                    dLambda=1-prevLambda;
                    lambda=1;
                else
                    lambda=min(prevLambda+dLambda,1);
                end
                self.fprintf('lambda=%.3g prevLambda=%.3g dLambda=%.3g\n',...
                lambda,prevLambda,dLambda)


                self.fprintf(...
                '\tNORM(F,INF)\t\tNORM(DELTA,INF)\tLIMITED\tRESIDUE\tDELTA\n')
                for i=1:self.Parameters.OpMaxIters


                    evaluateJacobian=...
                    mod(i,self.Parameters.OpJacobianUpdatePeriod)==0;
                    evaluate(self,x,evaluateJacobian,beta);
                    if any(~isfinite(self.Residue))
                        break
                    end


                    residueConverged=self.checkResidue();

                    success=i>1&&residueConverged&&deltaConverged;
                    if success
                        break
                    end


                    [delta,solved]=self.solve(self.Residue);
                    if~solved||any(~isfinite(delta))
                        break
                    end


                    deltaConverged=self.checkDelta(x,delta);

                    success=i>1&&residueConverged&&deltaConverged;
                    if success
                        break
                    end


                    [x,limited]=self.update(x,delta);
                    if limited
                        deltaConverged=false;
                    end

                    iters=iters+1;

                    self.fprintf('%-2d\t%.6e\t%.6e\t%d\t\t%d\t\t%d\n',...
                    i,norm(self.Residue,inf),norm(delta,inf),...
                    limited,residueConverged,deltaConverged)
                end
                if i>1&&i<self.Parameters.OpMaxIters
                    self.fprintf('%-2d\t%.6e\t%.6e\t%d\t\t%d\t\t%d\n',...
                    i,norm(self.Residue,inf),norm(delta,inf),...
                    limited,residueConverged,deltaConverged)
                end

                if success


                    if lambda>1-100*eps
                        break
                    end



                    dXdLambda=self.solve([self.Evaluator.Uiv;zeros(N-1,1)]);


                    dx=dXdLambda*dLambda;
                    dx(dx>self.Parameters.OpVoltageLimit)=...
                    self.Parameters.OpVoltageLimit;
                    dx(dx<-self.Parameters.OpVoltageLimit)=...
                    -self.Parameters.OpVoltageLimit;
                    x=x+dx;



                    dLambda=min(dLambda*(1+5/i),1-lambda);
                    prevLambda=lambda;
                else


                    dLambda=dLambda/3;
                    if lambda<1e-20
                        break
                    end

                    dx=dXdLambda*dLambda;
                    dx(dx>self.Parameters.OpVoltageLimit)=...
                    self.Parameters.OpVoltageLimit;
                    dx(dx<-self.Parameters.OpVoltageLimit)=...
                    -self.Parameters.OpVoltageLimit;
                    x=x0+dx;
                end
            end
            self.Lambda=lambda;
        end

        function[delta,success]=solve(self,residue)

            lastwarn('');
            w1=warning('off','MATLAB:singularMatrix');
            w2=warning('off','MATLAB:illConditionedMatrix');
            w3=warning('off','MATLAB:nearlySingularMatrix');

            delta=full(self.U\(self.L\(self.P*residue)));
            success=true;

            if~isempty(lastwarn)

                if any(~isfinite(delta))||...
                    norm(self.Jacobian*delta-residue)...
                    >1e-3*norm(residue)
                    success=false;
                    self.fprintf(lastwarn);
                end
            end


            warning(w1)
            warning(w2)
            warning(w3)
        end

        function[x,is_limited]=update(self,x,delta)




            vLimit=self.Parameters.OpVoltageLimit;
            is_limited=any(abs(delta)>vLimit);
            delta(delta>vLimit)=vLimit;
            delta(delta<-vLimit)=-vLimit;

            x=x-delta;
        end

        function converged=checkDelta(self,x,dx)
            converged=...
            all(abs(dx)...
            <self.Parameters.RelTol*abs(x)+self.Parameters.AbsTol);
        end

        function converged=checkResidue(self)
            converged=all(abs(self.Residue)<self.AllowedResidueError);
        end

        function fprintf(self,varargin)
            if self.Parameters.OpVerbose
                fprintf(varargin{:});
            end
        end
    end
end
