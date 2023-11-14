function[oppoint,opreport,exitflag,output]=optimize(this)

    X=[this.x0;this.u0];
    LB=[this.lbx;this.lbu];
    UB=[this.ubx;this.ubu];
    OptimOptions=this.linoptions.OptimizationOptions;
    if strcmp(OptimOptions.Jacobian,'on')
        if~isempty(feval(this.model,[],[],[],'constraints'))
            ctrlMsgUtils.error('Slcontrol:findop:AnalyticJacobianConstraintNotAllowed',this.model)
        end
        OptimOptions.GradObj='on';
        OptimOptions.GradConstr='on';
    else
        OptimOptions.GradObj='off';
        OptimOptions.GradConstr='off';
    end


    if isempty(this.opcond.CustomObjFcn)
        OptimOptions.GradObj='on';
    end


    callOptim=isfield(OptimOptions,'Algorithm')&&~strcmp(OptimOptions.Algorithm,'active-set')...
    &&~isempty(ver('optim'))&&license('test','Optimization_Toolbox');

    if callOptim
        [X,fval,exitflag,output]=fmincon(@LocalFunctionEval,X,...
        [],[],[],[],LB,UB,...
        @LocalNonlinearConstraint,...
        OptimOptions,this);
    else
        [X,fval,exitflag,output]=scdconstrsh(@LocalFunctionEval,X,...
        [],[],[],[],LB,UB,...
        @LocalNonlinearConstraint,...
        OptimOptions,this);
    end


    x=X(1:length(this.x0));
    u=X(length(this.x0)+1:end);


    xstruct=setx(this,x);


    [oppoint,opreport]=computeresults(this,xstruct,u);


    function[F,G]=LocalFunctionEval(X,this)

        UpdateErrors(this,X);



        IX=[this.ix(:);this.iu(:)+numel(this.x0)];


        err=[this.F_x(:);this.F_u(:)];
        [F,ind]=max(abs(err));

        if nargout>1



            G=zeros(size(X));
            if abs(F)>eps
                if numel(IX)
                    G(IX(ind))=sign(err(ind));
                else
                    G(ind)=sign(err(ind));
                end
            end
            if~isempty(this.opcond.CustomObjFcn)
                G=G+LocalComputeGradient(this);
            end
        end
        if~isempty(this.F_cost)
            F=F+this.F_cost;
        end

        function[c,ceq,Gc,Gceq]=LocalNonlinearConstraint(X,this)










            UpdateErrors(this,X);

            Gceq=[];Gc=[];

            ceq=[this.F_dx(:);
            this.F_y(:);
            this.F_const(:);
            this.F_cceq(:)];
            c=this.F_ccieq;

            if nargout>2
                [~,Gcceq,Gccieq]=LocalComputeGradient(this);
                Gceq=Gcceq;
                Gc=Gccieq;
            end



            function[Gcost,Gcceq,Gccieq]=LocalComputeGradient(this)





                [A,B,C,D,C0,D0]=sortJacobian(this);


                G_cost_x=this.G_cost_x+C0'*this.G_cost_y;
                G_cost_u=this.G_cost_u+D0'*this.G_cost_y;



                G_cceq_x=this.G_cceq_x+C0'*this.G_cceq_y;
                G_cceq_u=this.G_cceq_u+D0'*this.G_cceq_y;


                G_ccieq_x=this.G_ccieq_x+C0'*this.G_ccieq_y;
                G_ccieq_u=this.G_ccieq_u+D0'*this.G_ccieq_y;


                ind=(this.F_ccieq<0);
                G_ccieq_x(:,ind)=0;
                G_ccieq_u(:,ind)=0;


                Ablast=A(this.ibdx,:);
                Bblast=B(this.ibdx,:);

                freeIdx=(this.F_dx(1:numel(this.ibdx))==0);
                Ablast(freeIdx,:)=0;
                Bblast(freeIdx,:)=0;






                Gcost=[G_cost_x(:,:);G_cost_u(:,:)];

                if~isempty(G_cceq_x)
                    Gcceq=full([Ablast',A(this.idx,:)',C',G_cceq_x;
                    Bblast',B(this.idx,:)',D',G_cceq_u]);
                else
                    Gcceq=full([Ablast',A(this.idx,:)',C';
                    Bblast',B(this.idx,:)',D']);
                end

                if~isempty(G_ccieq_x)
                    Gccieq=[G_ccieq_x;
                    G_ccieq_u];
                else
                    Gccieq=[];
                end

