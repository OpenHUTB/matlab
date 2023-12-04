function[f,bineq,beq,lb,ub]=checkInputSize(f,socConstraints,Aineq,bineq,Aeq,beq,lb,ub)
    emptyProblem=isempty(f)&&isempty(socConstraints)&&...
    isempty(Aineq)&&isempty(bineq)&&...
    isempty(Aeq)&&isempty(beq)&&...
    isempty(lb)&&isempty(ub);
    assert(~emptyProblem,message('optim:coneprog:EmptyProblem'));


    n=0;
    if~isempty(socConstraints)
        n=size(socConstraints(1).A,2);
    end
    nf=numel(f);
    nineq=size(Aineq,2);
    neq=size(Aeq,2);
    nlb=numel(lb);
    nub=numel(ub);
    n=max([n,nf,nineq,neq,nlb,nub]);


    if nf==0
        f=zeros(n,1);
    else
        f=full(f(:));
    end


    if nlb==0
        lb=-Inf(n,1);
    else
        assert(n==nlb,message('optim:coneprog:SizeMismatchLB'));
        lb=full(lb(:));
    end
    if nub==0
        ub=Inf(n,1);
    else
        assert(n==nub,message('optim:coneprog:SizeMismatchUB'));
        ub=full(ub(:));
    end


    bineq=full(bineq(:));
    beq=full(beq(:));


    for i=1:numel(socConstraints)


        assert(size(socConstraints(i).A,2)==n,message('optim:coneprog:SizeMismatchColsOfSocA'));
        assert(numel(socConstraints(i).d)==n,message('optim:coneprog:SizeMismatchSocD'));


        assert(size(socConstraints(i).A,1)==size(socConstraints(i).b,1),...
        message('optim:coneprog:SizeMismatchRowsOfSocA'));
        assert(isscalar(socConstraints(i).gamma),...
        message('optim:coneprog:SizeMismatchSocGamma'));

    end



    if~isempty(Aineq)&&nineq~=n
        error(message('optim:coneprog:SizeMismatchColsOfA'));
    end

    if~isempty(Aeq)&&neq~=n
        error(message('optim:coneprog:SizeMismatchColsOfAeq'));
    end


    assert(size(Aineq,1)==size(bineq,1),message('optim:coneprog:SizeMismatchRowsOfA'));
    assert(size(Aeq,1)==size(beq,1),message('optim:coneprog:SizeMismatchRowsOfAeq'));

end
