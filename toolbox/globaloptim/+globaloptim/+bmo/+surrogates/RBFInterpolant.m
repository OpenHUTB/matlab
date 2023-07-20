





























































classdef RBFInterpolant<APIs.SurrogateFitter

    properties(Access=private)


fX
        capacity=500
m_
        dirty=false
L
U
piv
        mu=1e-6

        havesizes=false;
        allocated=false;
        initialized=false;
        CheckDistance=true;
        options=[];
        AlwaysFullFactor=false;
        show_tail_warn=true;
        show_lu_update_warn=true;
        show_solve_warn=true;
    end

    properties
        fitOK=false
        have_gradients=true
        have_hessian=true
    end

    methods

        function self=RBFInterpolant(setup,options)

            self.SurrogateEvaluator=globaloptim.bmo.surrogates.CompactRBF;


            if nargin>1
                self.options=options;
            end



            if nargin>0
                setup.nvar=numel(setup.ub);
                self.setSizes(setup);
                self.setOptions(setup,self.options);
            end
        end


        function designs=fitImpl(self,expensiveDataStorage,dataIndex,vectorized)

            designs=[];

            if nargin<4
                vectorized=true;
                if nargin<3
                    dataIndex=[];
                end
            end

            if~self.havesizes
                x=expensiveDataStorage.getIndependentVariable();
                setup.nvar=size(x,2);
                setup.lb=-100*ones(setup.nvar,1);
                setup.ub=-setup.lb;
                self.setSizes(setup);
                self.setOptions(setup,self.options);
            end

            if~self.allocated
                self.allocate(expensiveDataStorage);
                self.SurrogateEvaluator.responseCol=expensiveDataStorage.responseCol;
                self.SurrogateEvaluator.responseNames=expensiveDataStorage.getResponseNames();
            end


            if self.initialized
                self.reset();
            end
            self.initialized=true;


            newX=expensiveDataStorage.getIndependentVariable();
            newfX=expensiveDataStorage.getResponsesMat();
            if~isempty(dataIndex)
                newX=newX(dataIndex,:);
                newfX=newfX(dataIndex,:);
            end
            self.addPoints(newX,newfX,vectorized);
        end

        function designs=updateImpl(self,expensiveDataStorage,dataIndex)


            designs=[];

            assert(self.initialized);


            newX=expensiveDataStorage.getIndependentVariable();
            newfX=expensiveDataStorage.getResponsesMat();
            if nargin==3
                newX=newX(dataIndex,:);
                newfX=newfX(dataIndex,:);
            end
            self.addPoints(newX,newfX,false);
            self.SurrogateEvaluator.Ylast=[];
            self.SurrogateEvaluator.YlastScaled=[];
        end


        function dim=getDim(self)

            dim=self.SurrogateEvaluator.dim;
        end
        function X=getX(self)

            X=self.SurrogateEvaluator.X(1:self.SurrogateEvaluator.numPoints,:);
            if~isempty(X)&&~isempty(self.SurrogateEvaluator.lb)&&~isempty(self.SurrogateEvaluator.ub)
                X=globaloptim.bmo.surrogates.CompactRBF.mapFromUnit(X,...
                self.SurrogateEvaluator.lb,self.SurrogateEvaluator.ub,self.SurrogateEvaluator.fixedID);
            end
        end
        function X=getXScaled(self)

            X=self.SurrogateEvaluator.X(1:self.SurrogateEvaluator.numPoints,:);
        end
        function fX=getfX(self)

            fX=self.fX(1:self.SurrogateEvaluator.numPoints,:);
        end

        function npts=getMinNumPoints(self)
            npts=self.SurrogateEvaluator.tail.getDimBasis();
        end
        function npts=getNumPoints(self)

            npts=self.SurrogateEvaluator.numPoints;
        end

    end

    methods(Access=private)

        function setSizes(self,setup)

            if~any(isinf(setup.lb))&&~any(isinf(setup.ub))
                self.SurrogateEvaluator.lb=setup.lb(:);
                self.SurrogateEvaluator.ub=setup.ub(:);
                self.SurrogateEvaluator.dim=setup.nvar;
            end


            self.SurrogateEvaluator.Range=self.SurrogateEvaluator.ub-self.SurrogateEvaluator.lb;
            self.SurrogateEvaluator.fixedID=self.SurrogateEvaluator.Range<=self.SurrogateEvaluator.dTol;

            if self.SurrogateEvaluator.DEBUG
                self.checkInputs();
            end
            self.havesizes=true;
        end

        function setOptions(self,sizes,options)
            if isfield(options,'Verbosity')
                self.SurrogateEvaluator.Verbosity=options.Verbosity;
            end

            if isfield(options,'rbf_capacity')
                self.capacity=options.rbf_capacity;
            end

            if isfield(options,'rbf_mu')
                self.mu=options.rbf_mu;
            end

            if~isfield(options,'rbf_kernel')
                self.SurrogateEvaluator.kernel=globaloptim.bmo.surrogates.kernels.CubicKernel;
                self.SurrogateEvaluator.tail=globaloptim.bmo.surrogates.tails.LinearTail(sizes);

            elseif ischar(options.rbf_kernel)
                if~isfield(options,'rbf_tail')
                    error(message('globaloptim:bmo:RbfKernelThenTailRequired'));
                end
                self.SurrogateEvaluator.kernel=feval(options.rbf_kernel);
                self.SurrogateEvaluator.tail=feval(options.rbf_tail,sizes,options);

            else
                self.SurrogateEvaluator.kernel=options.rbf_kernel;
                self.SurrogateEvaluator.tail=options.rbf_tail;
            end

            if isfield(options,'perturbX')
                self.SurrogateEvaluator.perturbX=options.perturbX;
            end

            if isfield(options,'ScalingFcn')&&...
                ~strcmpi(options.ScalingFcn,'none')

                self.SurrogateEvaluator.fScaled=true;

                if strcmpi(options.ScalingFcn,'logscale')
                    self.SurrogateEvaluator.filter=...
                    globaloptim.bmo.surrogates.fscale.LogScale;
                elseif isa(options.ScalingFcn,'globaloptim.bmo.surrogates.fscale.FcnScale')

                    self.SurrogateEvaluator.filter=options.ScalingFcn;
                end

                if isfield(options,'unscaleResponse')



                    self.SurrogateEvaluator.unscaleResponse=options.unscaleResponse;
                end
            end
            if isfield(options,'CheckDistance')
                self.CheckDistance=options.CheckDistance;
            end

            if isfield(options,'DEBUG')
                self.SurrogateEvaluator.DEBUG=options.DEBUG;
            end

        end


        function allocate(self,expensiveDataStorage)

            self.SurrogateEvaluator.nResponse=expensiveDataStorage.nResponses;


            self.SurrogateEvaluator.X=zeros(self.capacity,self.SurrogateEvaluator.dim);
            self.fX=zeros(self.capacity,self.SurrogateEvaluator.nResponse);
            self.m_=self.capacity+self.SurrogateEvaluator.tail.getDimBasis();
            self.L=zeros(self.m_,self.m_);
            self.U=zeros(self.m_,self.m_);
            self.piv=zeros(self.m_,1);
            self.allocated=true;

        end

        function reset(self)


            self.SurrogateEvaluator.X=zeros(size(self.SurrogateEvaluator.X));
            self.fX=zeros(size(self.fX));
            self.SurrogateEvaluator.numPoints=0;
            self.SurrogateEvaluator.w=[];
            self.SurrogateEvaluator.lambda=[];
            self.SurrogateEvaluator.c=[];
            self.dirty=false;
            self.fitOK=false;
        end

        function addPoints(self,newX,newfX,vectorized)





            id_=false(size(newX,1),1);
            for ii=1:size(newX,1)
                id_(ii)=~isreal(newfX(ii,:))|~all(isfinite(newfX(ii,:)));
                id_(ii)=id_(ii)|~isreal(newX(ii,:))|~all(isfinite(newX(ii,:)));
            end

            if any(id_)
                newX(id_,:)=[];
                newfX(id_,:)=[];

                if isempty(newfX)
                    if self.SurrogateEvaluator.Verbosity>=3
                        fprintf(' %d Points or function values are either NaN, Inf or not real; Not adding to the surrogate.\n',nnz(id_))
                    end
                    return;
                end
            elseif isempty(newX)

                if self.SurrogateEvaluator.Verbosity>=3
                    fprintf('No new points provided to fit/update RBF.\n');
                end
                return;
            end


            if self.SurrogateEvaluator.numPoints+length(newfX)>self.capacity


                K=self.capacity;
                M=(ceil(((self.SurrogateEvaluator.numPoints+length(newfX))/K))*K-K);

                self.SurrogateEvaluator.X=[self.SurrogateEvaluator.X;zeros(M,self.SurrogateEvaluator.dim)];
                self.fX=[self.fX;zeros(M,self.SurrogateEvaluator.nResponse)];
                self.L=[self.L,zeros(self.m_,M);...
                zeros(M,self.m_),...
                zeros(M,M)];
                self.U=[self.U,zeros(self.m_,M);...
                zeros(M,self.m_),...
                zeros(M,M)];
                self.piv=[self.piv;zeros(M,1)];
                self.capacity=self.capacity+M;
                self.m_=self.capacity+self.SurrogateEvaluator.tail.getDimBasis();
            end


            if~isempty(self.SurrogateEvaluator.lb)&&~isempty(self.SurrogateEvaluator.ub)

                if~self.SurrogateEvaluator.perturbX&&...
                    1/cond([self.getX();newX])<sqrt(eps)


                    self.SurrogateEvaluator.perturbX=true;
                    if self.SurrogateEvaluator.Verbosity>=3
                        disp('Adding perturbations to the design matrix.')
                    end
                end

                if vectorized
                    newX=globaloptim.bmo.surrogates.CompactRBF.mapToUnit(...
                    newX,self.SurrogateEvaluator.lb,...
                    self.SurrogateEvaluator.ub,...
                    self.SurrogateEvaluator.fixedID,...
                    self.SurrogateEvaluator.perturbX);
                else
                    for ii=1:size(newX,1)


                        newX(ii,:)=globaloptim.bmo.surrogates.CompactRBF.mapToUnit(...
                        newX(ii,:),self.SurrogateEvaluator.lb,...
                        self.SurrogateEvaluator.ub,...
                        self.SurrogateEvaluator.fixedID,...
                        self.SurrogateEvaluator.perturbX);
                    end

                end
            end

            if self.CheckDistance

                allX=self.SurrogateEvaluator.X(1:self.SurrogateEvaluator.numPoints,:);
                if~isempty(allX)
                    allDist=self.SurrogateEvaluator.DistanceFcn(newX,allX);
                else

                    allDist=self.SurrogateEvaluator.DistanceFcn(newX)+...
                    10*self.SurrogateEvaluator.dTol*eye(size(newX,1));
                end
                mindist=min(allDist,[],2);
                to_keep=mindist>=self.SurrogateEvaluator.dTol;

                if isempty(allX)&&~any(to_keep)

                    to_keep(1)=true;
                end

                if~any(to_keep)

                    if self.SurrogateEvaluator.Verbosity>=3
                        fprintf('Minimum distance violated, centers closer than %.3e\n',self.SurrogateEvaluator.dTol)
                    end
                    return;
                elseif~all(to_keep)

                    newX=newX(to_keep,:);
                    newfX=newfX(to_keep,:);
                end
            end


            start=self.SurrogateEvaluator.numPoints+1;
            last=self.SurrogateEvaluator.numPoints+size(newX,1);
            self.SurrogateEvaluator.X(start:last,:)=newX;
            self.fX(start:last,:)=newfX;
            self.SurrogateEvaluator.numPoints=self.SurrogateEvaluator.numPoints+size(newX,1);


            self.dirty=true;
            self.fitImpl_noWarn();

            if self.dirty

                self.SurrogateEvaluator.numPoints=...
                self.SurrogateEvaluator.numPoints-size(newX,1);
            end
        end

        function fitImpl_noWarn(self)




            if~self.dirty||self.getNumPoints()<self.getMinNumPoints()
                return
            end


            if self.SurrogateEvaluator.numPoints<self.SurrogateEvaluator.tail.getDimBasis()
                error(message('globaloptim:bmo:notEnoughPointsToFitRBF'));
            end


            bbl=min(self.SurrogateEvaluator.X(1:self.SurrogateEvaluator.numPoints,:));
            bbu=max(self.SurrogateEvaluator.X(1:self.SurrogateEvaluator.numPoints,:));
            if self.SurrogateEvaluator.Verbosity>=3&&max(bbu-bbl)>100
                fprintf(['Warning: Domain seems badly scaled and this can make the RBF ',...
                'interpolant\n\tvery inaccurate. Consider scaling your domain to [0,1]^d\n'])
            end


            if isempty(self.SurrogateEvaluator.w)||self.AlwaysFullFactor

                self.FactorAndSolve()
            else

                self.updateFactorsAndSolve()
            end

            if~isempty(self.SurrogateEvaluator.w)
                self.fitOK=true;
            end
        end


        function FactorAndSolve(self)




            import matlab.internal.math.nowarn.mldivide
            import matlab.internal.math.nowarn.mrdivide
            n=self.SurrogateEvaluator.numPoints;
            m=self.SurrogateEvaluator.tail.getDimBasis();
            XX=self.SurrogateEvaluator.X(1:n,:);
            fXX=self.SurrogateEvaluator.filter.scale(self.fX(1:n,:));

            D=self.SurrogateEvaluator.DistanceFcn(XX);
            Phi=self.SurrogateEvaluator.kernel.eval(D)+self.mu*eye(n);
            P=self.SurrogateEvaluator.tail.eval(XX);

            if rank(P)~=min(size(P))



                self.SurrogateEvaluator.tail.tail_constant=randn;
                P=self.SurrogateEvaluator.tail.eval(XX);
                if self.show_tail_warn&&self.SurrogateEvaluator.Verbosity>=3
                    disp('RBF tail is rank deficient.')
                    self.show_tail_warn=false;
                end
            end

            A=[zeros(m,m),P';P,Phi];

            if~self.AlwaysFullFactor&&rank(A)~=min(size(A))
                self.AlwaysFullFactor=true;
                if self.show_lu_update_warn&&self.SurrogateEvaluator.Verbosity>=3
                    disp('RBF system is rank deficient.')
                    self.show_lu_update_warn=false;
                end
            end

            [L11,U11,piv1]=lu(A,'vector');
            self.L(1:n+m,1:n+m)=L11;
            self.U(1:n+m,1:n+m)=U11;
            self.piv(1:n+m)=piv1;
            rhs=[zeros(m,self.SurrogateEvaluator.nResponse);fXX];

            self.SurrogateEvaluator.w=U11\(L11\rhs(piv1,:));
            if~all(isfinite(self.SurrogateEvaluator.w(:)))

                if self.show_solve_warn&&self.SurrogateEvaluator.Verbosity>=3
                    disp('Matrix is singular to working precision; Points not well poised.')
                    self.show_solve_warn=false;
                end
                if~self.SurrogateEvaluator.perturbX
                    self.SurrogateEvaluator.perturbX=true;
                    if self.SurrogateEvaluator.Verbosity>=3
                        disp('Adding perturbations to the design matrix.')
                    end
                end
                self.SurrogateEvaluator.w=[];
            else
                self.SurrogateEvaluator.c=self.SurrogateEvaluator.w(1:m,:);
                self.SurrogateEvaluator.lambda=self.SurrogateEvaluator.w(m+1:end,:);

                self.dirty=false;
            end

        end


        function updateFactorsAndSolve(self)







            import matlab.internal.math.nowarn.mldivide
            import matlab.internal.math.nowarn.mrdivide

            n=size(self.SurrogateEvaluator.lambda,1);
            k=self.SurrogateEvaluator.numPoints-n;
            m=self.SurrogateEvaluator.tail.getDimBasis();
            self.piv(m+n+1:m+n+k)=m+n+1:m+n+k;

            oldXX=self.SurrogateEvaluator.X(1:n,:);
            newXX=self.SurrogateEvaluator.X(n+1:n+k,:);
            D=self.SurrogateEvaluator.DistanceFcn(oldXX,newXX);

            B=[self.SurrogateEvaluator.tail.eval(newXX)';...
            self.SurrogateEvaluator.kernel.eval(D)];
            D2=self.SurrogateEvaluator.DistanceFcn(newXX);
            C=self.SurrogateEvaluator.kernel.eval(D2)+self.mu*eye(k);
            L21=B'/self.U(1:m+n,1:m+n);
            U12=self.L(1:m+n,1:m+n)\B(self.piv(1:n+m),:);
            [L22,p]=chol(C-L21*U12,'lower');
            if p~=0

                if self.show_solve_warn&&self.SurrogateEvaluator.Verbosity>=3
                    disp('Matrix is close to singular or badly scaled. Rejecting new points in the surrogate.')
                end
                if~self.SurrogateEvaluator.perturbX
                    self.SurrogateEvaluator.perturbX=true;
                    if self.SurrogateEvaluator.Verbosity>=3
                        disp('Adding perturbations to the design matrix.')
                    end
                end

                self.AlwaysFullFactor=true;

            else
                self.L(m+n+1:m+n+k,1:m+n)=L21;
                self.L(m+n+1:m+n+k,m+n+1:m+n+k)=L22;
                self.U(1:m+n,m+n+1:m+n+k)=U12;
                self.U(m+n+1:m+n+k,m+n+1:m+n+k)=L22';
                rhs=[zeros(m,self.SurrogateEvaluator.nResponse);
                self.SurrogateEvaluator.filter.scale(self.fX(1:n+k,:))];

                self.SurrogateEvaluator.w=self.U(1:m+n+k,1:m+n+k)\(self.L(1:m+n+k,1:m+n+k)\rhs(self.piv(1:m+n+k),:));
                self.SurrogateEvaluator.c=self.SurrogateEvaluator.w(1:m,:);
                self.SurrogateEvaluator.lambda=self.SurrogateEvaluator.w(m+1:end,:);

                self.dirty=false;
            end
        end


        function checkInputs(self)


            assert(~isempty(self.SurrogateEvaluator.lb)&&~isempty(self.SurrogateEvaluator.ub),...
            'lb and ub are required.')

            assert(all(self.SurrogateEvaluator.lb<=self.SurrogateEvaluator.ub),...
            'lb must be smaller than ub')

            assert(self.SurrogateEvaluator.dim==length(self.SurrogateEvaluator.lb)&&self.SurrogateEvaluator.dim==length(self.SurrogateEvaluator.ub),...
            'lb and ub have the wrong size');

            assert(length(self.SurrogateEvaluator.lb)==length(self.SurrogateEvaluator.ub),...
            'lb and ub must have the same length');

            assert(all(isfinite(self.SurrogateEvaluator.lb))&&all(isfinite(self.SurrogateEvaluator.ub)),...
            'lb/ub must be finite');

            assert(self.SurrogateEvaluator.dim>=1&&round(self.SurrogateEvaluator.dim)==self.SurrogateEvaluator.dim,...
            'dim must be a positive integer');

            assert(self.capacity>=1&&round(self.capacity)==self.capacity,...
            'capacity must be a positive integer');

            assert(self.mu>=0&&isfinite(self.mu),...
            'mu must be non-negative and finite');

            assert(isa(self.SurrogateEvaluator.kernel,'globaloptim.bmo.surrogates.kernels.Kernel'),...
            'The kernel does not implement Kernel');

            assert(isa(self.SurrogateEvaluator.tail,'globaloptim.bmo.surrogates.tails.Tail'),...
            'The tail does not implement Tail');

            assert(self.SurrogateEvaluator.tail.getDim()==self.SurrogateEvaluator.dim,...
            'The tail dimension is different from RBF dimension');

            assert(~(self.SurrogateEvaluator.kernel.getOrder()-1>self.SurrogateEvaluator.tail.getDegree()),...
            'Kernel and tail mismatch');

            assert(length(self.SurrogateEvaluator.filter.scale(randn(100,1)))==100,...
            'Incorrect filter');

        end

    end

end
