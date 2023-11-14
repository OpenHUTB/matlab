function[oppoint,opreport,exitflag,output]=optimize(this)
    X=[this.x0(this.indx);this.u0(this.indu)];
    LB=[this.lbx(this.indx);this.lbu(this.indu)];
    UB=[this.ubx(this.indx);this.ubu(this.indu)];

    OptimOptions=this.linoptions.OptimizationOptions;
    if strcmp(OptimOptions.Jacobian,'on')
        if~isempty(feval(this.model,[],[],[],'constraints'))
            ctrlMsgUtils.error('Slcontrol:findop:AnalyticJacobianConstraintNotAllowed',this.model)
        end
        OptimOptions.GradConstr='on';
    else
        OptimOptions.GradConstr='off';
    end


    if isempty(this.opcond.CustomObjFcn)
        OptimOptions.GradObj='on';
    else
        OptimOptions.GradObj='off';
    end


    callOptim=isfield(OptimOptions,'Algorithm')&&~strcmp(OptimOptions.Algorithm,'active-set')...
    &&~isempty(ver('optim'))&&license('test','Optimization_Toolbox');


    if callOptim
        [X,~,exitflag,output]=fmincon(@LocalFunctionEval,X,...
        [],[],[],[],LB,UB,...
        @LocalNonlinearConstraint,...
        OptimOptions,this);
    else
        [X,~,exitflag,output]=scdconstrsh(@LocalFunctionEval,X,...
        [],[],[],[],LB,UB,...
        @LocalNonlinearConstraint,...
        OptimOptions,this);
    end


    x=this.x0;
    x(this.indx)=X(1:length(this.indx));
    u=this.u0;
    u(this.indu)=X(length(this.indx)+1:end);


    xstruct=setx(this,x);


    [oppoint,opreport]=computeresults(this,xstruct,u);

end


function[F,G]=LocalFunctionEval(X,this)



    if isempty(this.opcond.CustomObjFcn)
        F=0;
        G=zeros(size(X));
    else
        UpdateErrors(this,X);




        F=this.F_cost;
        if nargout>1
            G=LocalComputeGradient(this);
        else
            G=[];
        end
    end
end


function[c,ceq,Gc,Gceq]=LocalNonlinearConstraint(X,this)

    UpdateErrors(this,X);

    Gceq=[];Gc=[];

    useJacobian=nargout>2;

    ceq=[this.F_dx(:);
    this.F_y(:);
    this.F_const(:);
    this.F_cceq];
    c=this.F_ccieq;


    if useJacobian
        [~,Gcceq,Gccieq]=LocalComputeGradient(this);
        Gceq=Gcceq;
        Gc=Gccieq;
    end
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
    Gcost=[G_cost_x(this.indx,:);G_cost_u(this.indu,:)];


    Ablast=A(this.ibdx,this.indx);
    Bblast=B(this.ibdx,this.indu);

    freeIdx=(this.F_dx(1:numel(this.ibdx))==0);
    Ablast(freeIdx,:)=0;
    Bblast(freeIdx,:)=0;


    if~isempty(G_cceq_x)
        Gcceq=full([Ablast',A(this.idx,this.indx)',C(:,this.indx)',G_cceq_x(this.indx,:);
        Bblast',B(this.idx,this.indu)',D(:,this.indu)',G_cceq_u(this.indu,:)]);
    else
        Gcceq=full([Ablast',A(this.idx,this.indx)',C(:,this.indx)';
        Bblast',B(this.idx,this.indu)',D(:,this.indu)']);
    end

    if~isempty(G_ccieq_x)
        Gccieq=[G_ccieq_x(this.indx,:);
        G_ccieq_u(this.indu,:)];
    else
        Gccieq=[];
    end

end