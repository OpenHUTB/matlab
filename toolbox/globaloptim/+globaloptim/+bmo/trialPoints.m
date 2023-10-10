function cand=trialPoints(adaptiveSamplerHandle,nPoints,xc,Xin,method,evalCount,trialData)
    solverData=adaptiveSamplerHandle.Data;
    problem=adaptiveSamplerHandle.problem;
    minDelta=solverData.sigmaMin*problem.range;

    if~isempty(method)&&...
        (~isempty(problem.Aineq)||~isempty(problem.Aeq))

        cand=linearFeasibleCandidates(nPoints,[xc;Xin],adaptiveSamplerHandle,trialData,method);

    elseif strcmpi(method,'random')||isempty(method)

        cand=randomSamples(nPoints,xc,...
        solverData.scaledSamplingRadius,...
        problem,adaptiveSamplerHandle.options,evalCount,trialData);

    elseif strcmpi(method,'gps')
        cand=gpsCandidates(nPoints,[xc;Xin],...
        solverData.scaledSamplingRadius,minDelta,...
        problem,adaptiveSamplerHandle.options,trialData);

    elseif strcmpi(method,'ortho')
        cand=orthomadsCandidates(nPoints,[xc;Xin],...
        solverData.scaledSamplingRadius,minDelta,...
        problem,adaptiveSamplerHandle.options,adaptiveSamplerHandle.useQuasi,trialData);

    elseif strcmpi(method,'gps-ortho')
        cand1=gpsCandidates(nPoints,[xc;Xin],...
        solverData.scaledSamplingRadius,minDelta,...
        problem,adaptiveSamplerHandle.options,trialData);

        npts=nPoints-size(cand1,1);
        cand2=orthomadsCandidates(npts,[xc;Xin],...
        solverData.scaledSamplingRadius,minDelta,...
        problem,adaptiveSamplerHandle.options,adaptiveSamplerHandle.useQuasi,trialData);
        cand=[cand1;cand2];

    elseif strcmpi(method,'ortho-random')
        cand1=orthomadsCandidates(nPoints,[xc;Xin],...
        solverData.scaledSamplingRadius,minDelta,...
        problem,adaptiveSamplerHandle.options,adaptiveSamplerHandle.useQuasi,trialData);

        npts=nPoints-size(cand1,1);
        cand2=randomSamples(npts,xc,...
        solverData.scaledSamplingRadius,...
        problem,adaptiveSamplerHandle.options,evalCount,trialData);

        cand=[cand1;cand2];
    else
        assert(false)
    end

    if~isempty(cand)

        cand=uniquetol(cand,1e-10,'ByRows',true);
    end
end


function cand=randomSamples(nPoints,x0,delta0,problem,...
    options,evalCount,trialData)

    n=numel(x0);
    if nPoints==0
        cand=zeros(0,n);
        return
    end
    pert=nan(nPoints,n);
    vartype=problem.vartype;

    if nnz(vartype)>0
        pert(:,vartype)=sign(randn(nPoints,nnz(vartype))).*...
        rand(nPoints,nnz(vartype)).*...
        delta0(vartype)';
    end

    if nnz(~vartype)>0
        pert(:,~vartype)=randn(nPoints,nnz(~vartype)).*delta0(~vartype)';
    end

    if options.doDycors
        pert=randn(nPoints,n).*delta0';

        temp1=evalCount+1;
        temp2=options.MaxFunctionEvaluations;

        p=min(20/n,1)*(1-(log(temp1)/log(temp2)));
        p=max(p,1.0/n);
        non_neg=rand(nPoints,n)<p;


        ind=find(sum(non_neg,2)==0);
        if~isempty(ind)
            non_neg(ind,randi(n,length(ind),1))=1;
        end
        pert=pert.*non_neg;
    end

    cand=x0+pert;
    cand=globaloptim.bmo.boundAndRound(cand,problem,trialData,options);

end


function cand=gpsCandidates(nPoints,Xin,delta0,minDelta,problem,...
    options,trialData)

    n=size(Xin,2);
    if nPoints==0
        cand=zeros(0,n);
        return
    end
    vartype=problem.vartype;

    delta0(vartype)=max(2,delta0(vartype));
    lb=problem.lb;
    ub=problem.ub;

    cand=nan(nPoints,n);
    Idirs=eye(n);

    nDelta=20;

    minDelta=min(minDelta);

    row1=1;
    row2=1;

    for jj=1:size(Xin,1)
        x0=Xin(jj,:);
        delta=delta0;

        for kk=1:nDelta

            delta_next=delta/2.0;
            delta_next(vartype)=ceil(delta_next(vartype));

            if all(delta_next==delta)
                break;
            else
                delta=delta_next;
            end

            D=delta_next.*Idirs;
            Points=x0+[-sum(D,2),sum(D,2),D,-D]';
            feas=areTrialsBoundFeasible(Points,lb,ub);
            if~any(feas)
                continue;
            end

            Points=Points(feas,:);
            if nPoints==1
                cand(1,:)=Points(1,:);
            else
                row2=min(nPoints,(row1-1+nnz(feas)));
                cand(row1:row2,:)=Points(1:(row2-row1+1),:);
            end

            if row2>=nPoints||max(delta_next)<=minDelta
                break
            end
            row1=row2+1;

        end
    end

    cand(all(isnan(cand),2),:)=[];
    cand=globaloptim.bmo.boundAndRound(cand,problem,trialData,options);

end


function cand=linearFeasibleCandidates(nPoints,Xin,adaptiveSamplerHandle,trialData,method)


    n=size(Xin,2);
    if nPoints==0
        cand=zeros(0,n);
        return
    end

    problem=adaptiveSamplerHandle.problem;
    if contains(method,'ortho')&&isempty(problem.Aeq)

        BasisType='orthomads';
    else

        BasisType='coordinates';
    end
    options=adaptiveSamplerHandle.options;
    solverData=adaptiveSamplerHandle.Data;
    minDelta=solverData.sigmaMin*problem.range;
    delta0=solverData.scaledSamplingRadius;

    if size(Xin,1)>1
        delta0=min(minDelta*2,delta0);
    end

    delta0=mean(delta0);

    cand=nan(nPoints,n);


    nDelta=20;

    minDelta=min(minDelta);

    row1=1;
    row2=1;

    adaptiveSamplerHandle.PollPointGenerator.BasisType=BasisType;


    for jj=1:size(Xin,1)
        X0=Xin(jj,:)';
        [adaptiveSamplerHandle.PollPointGenerator,AllDirs]=...
        adaptiveSamplerHandle.PollPointGenerator.generateCoreDirections(...
        struct('x',X0,'meshsize',delta0),problem);
        if~isempty(AllDirs)

            AllDirs=[AllDirs,adaptiveSamplerHandle.PollPointGenerator.AugmentedDirs];
        else
            continue;
        end

        delta=delta0;
        for kk=1:nDelta

            Points=findFeasiblePoints(AllDirs,X0,delta,problem,trialData,options);
            if isempty(Points)
                break;
            end

            delta=delta/2.0;
            if nPoints==1
                cand(1,:)=Points(1,:);
            else
                row2=min(nPoints,(row1-1+size(Points,1)));
                cand(row1:row2,:)=Points(1:(row2-row1+1),:);
            end

            if row2>=nPoints||max(delta)<=minDelta
                break
            end
            row1=row2+1;

        end
    end


    cand(all(isnan(cand),2),:)=[];

    if false&&~isempty(cand)

        infeas=~globaloptim.internal.validate.isTrialFeasible(...
        cand,...
        problem.Aineq,problem.bineq,...
        problem.Aeq,problem.beq,...
        problem.lb,problem.ub,...
        options.ConstraintTolerance);
        assert(all(~infeas))
    end

end



function cand=orthomadsCandidates(nPoints,Xin,delta0,minDelta,problem,...
    options,useQuasi,trialData)

    if~useQuasi||true
        cand=orthoQRCandidates(nPoints,Xin,delta0,minDelta,problem,...
        options,trialData);
        return;
    end
end



function cand=orthoQRCandidates(nPoints,Xin,delta0,minDelta,problem,...
    options,trialData)

    n=size(Xin,2);
    if nPoints==0
        cand=zeros(0,n);
        return
    end
    lb=problem.lb;
    ub=problem.ub;
    vartype=problem.vartype;

    delta0(vartype)=max(2,delta0(vartype));

    cand=nan(nPoints,n);

    nDelta=20;

    minDelta=min(minDelta);

    row1=1;
    row2=1;

    [Q,~]=qr(rand(n));


    for jj=1:size(Xin,1)
        x0=Xin(jj,:);
        delta=delta0;

        for kk=1:nDelta

            delta_next=delta/2.0;
            delta_next(vartype)=ceil(delta_next(vartype));

            if all(delta_next==delta)
                break;
            else
                delta=delta_next;
            end

            D=delta_next.*Q;
            Points=x0+[-sum(D,2),sum(D,2),D,-D]';
            Points=globaloptim.bmo.boundAndRound(Points,problem,trialData,options);
            feas=areTrialsBoundFeasible(Points,lb,ub);
            if~any(feas)
                continue;
            end

            Points=Points(feas,:);
            if nPoints==1
                cand(1,:)=Points(1,:);
            else
                row2=min(nPoints,(row1-1+nnz(feas)));
                cand(row1:row2,:)=Points(1:(row2-row1+1),:);
            end

            if row2>=nPoints||max(delta_next)<=minDelta
                break
            end
            row1=row2+1;

        end
    end

    cand(all(isnan(cand),2),:)=[];

end


function feas=areTrialsBoundFeasible(X,lb,ub)

    argub=isfinite(ub);
    arglb=isfinite(lb);
    maxconstraint=zeros(size(X,1),1);

    if~isempty(argub)&&any(argub)
        maxconstraint=max(max(bsxfun(@minus,X(:,argub),ub(argub)'),[],2),maxconstraint);
    end

    if any(arglb)&&~isempty(arglb)
        maxconstraint=max(max(bsxfun(@minus,lb(arglb)',X(:,arglb)),[],2),maxconstraint);
    end
    feas=maxconstraint<=0;
end

function AllTrials=findFeasiblePoints(AllDirs,X0,meshsize,problem,trialData,options)

    AllTrials=[];
    if isempty(AllDirs)
        return
    end

    fullStep=AllDirs.*meshsize;

    if~isempty(problem.beq)
        maxconstraint=max(abs(problem.Aeq*fullStep),[],1);
        fullStep=fullStep(:,maxconstraint<=options.LinearConstraintTolerance);
    end

    if~isempty(fullStep)
        AllTrials=globaloptim.internal.directions.ratioTest(X0(:).',fullStep.',...
        problem.Aineq,problem.bineq,problem.lb,problem.ub,...
        options.LinearConstraintTolerance);
    end

end

