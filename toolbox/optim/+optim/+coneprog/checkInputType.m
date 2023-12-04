function checkInputType(f,socConstraints,A,b,Aeq,beq,lb,ub)

    msg=isoptimargdbl('CONEPROG',{'f','A','b','Aeq','beq','LB','UB'},...
    f,A,b,Aeq,beq,lb,ub);
    if~isempty(msg)
        error('optim:coneprog:NonDoubleInput',msg);
    end

    if~isempty(socConstraints)

        assert(isa(socConstraints,'optim.coneprog.SecondOrderConeConstraint'),...
        message('optim:coneprog:NonSOCInput'));

        assert(isvector(socConstraints),message('optim:coneprog:socConstraintsIsNotArray'));

    end

end
