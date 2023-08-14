function checkInputNanComplexInf(f,socConstraints,A,b,Aeq,beq,lb,ub)






    assert(~any(isnan(f)),message('optim:coneprog:InvalidElementInObjective','NaN'));
    assert(isreal(f),message('optim:coneprog:ComplexInObjective'));
    assert(~any(isinf(f)),message('optim:coneprog:InvalidElementInObjective','Inf'));

    for i=1:numel(socConstraints)
        assert(~any(isnan(socConstraints(i).A),'all'),message('optim:coneprog:InvalidElementInSocA','NaN'));
        assert(isreal(socConstraints(i).A),message('optim:coneprog:ComplexInSocA'));
        assert(~any(isinf(socConstraints(i).A),'all'),message('optim:coneprog:InvalidElementInSocA','Inf'));
        assert(~any(isnan(socConstraints(i).b)),message('optim:coneprog:InvalidElementInSocB','NaN'));
        assert(isreal(socConstraints(i).b),message('optim:coneprog:ComplexInSocB'));
        assert(~any(isinf(socConstraints(i).b)),message('optim:coneprog:InvalidElementInSocB','Inf'));
        assert(~any(isnan(socConstraints(i).d)),message('optim:coneprog:InvalidElementInSocD','NaN'));
        assert(isreal(socConstraints(i).d),message('optim:coneprog:ComplexInSocD'));
        assert(~any(isinf(socConstraints(i).d)),message('optim:coneprog:InvalidElementInSocD','Inf'));
        assert(~isnan(socConstraints(i).gamma),message('optim:coneprog:InvalidElementInSocGamma','NaN'));
        assert(isreal(socConstraints(i).gamma),message('optim:coneprog:ComplexInSocGamma'));
        assert(~isinf(socConstraints(i).gamma),message('optim:coneprog:InvalidElementInSocGamma','Inf'));
    end

    assert(~any(isnan(A),'all'),message('optim:coneprog:InvalidElementInA','NaN'));
    assert(isreal(A),message('optim:coneprog:ComplexInA'));
    assert(~any(isinf(A),'all'),message('optim:coneprog:InvalidElementInA','Inf'));

    assert(~any(isnan(b)),message('optim:coneprog:InvalidElementInB','NaN'));
    assert(isreal(b),message('optim:coneprog:ComplexInB'));
    assert(~any(isinf(b)),message('optim:coneprog:InvalidElementInB','Inf'));

    assert(~any(isnan(Aeq),'all'),message('optim:coneprog:InvalidElementInAeq','NaN'));
    assert(isreal(Aeq),message('optim:coneprog:ComplexInAeq'));
    assert(~any(isinf(Aeq),'all'),message('optim:coneprog:InvalidElementInAeq','Inf'));

    assert(~any(isnan(beq)),message('optim:coneprog:InvalidElementInBeq','NaN'));
    assert(isreal(beq),message('optim:coneprog:ComplexInBeq'));
    assert(~any(isinf(beq)),message('optim:coneprog:InvalidElementInBeq','Inf'));

    assert(~any(isnan(lb)),message('optim:coneprog:InvalidElementInLB','NaN'));
    assert(isreal(lb),message('optim:coneprog:ComplexInLB'));


    assert(~any(isnan(ub)),message('optim:coneprog:InvalidElementInUB','NaN'));
    assert(isreal(ub),message('optim:coneprog:ComplexInUB'));


end
