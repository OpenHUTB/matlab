function[mNonlinIneq,mNonlinEq]=checkNonlinearInputs(x0,objfun,nonlcon,options)













%#codegen

    coder.allowpcode('plain');



    coder.internal.prefer_const(x0,objfun,nonlcon,options);


    coder.internal.assert(coder.internal.isConst(isa(objfun,'function_handle'))&&isa(objfun,'function_handle'),'optimlib_codegen:common:InvalidObjectiveType');


    coder.internal.assert(isempty(nonlcon)||isa(nonlcon,'function_handle'),'optim_codegen:fmincon:InvalidConstraintType');

    if~isempty(nonlcon)


        if options.SpecifyConstraintGradient
            [Cineq,Ceq,JacCineqTrans,JacCeqTrans]=nonlcon(x0);


            coder.internal.assert(isempty(JacCineqTrans)||(size(JacCineqTrans,1)==numel(x0)&&size(JacCineqTrans,2)==numel(Cineq)),...
            'optimlib:fmincon:WrongSizeGradNonlinIneq',numel(x0),numel(Cineq));
            coder.internal.assert(isempty(JacCeqTrans)||(size(JacCeqTrans,1)==numel(x0)&&size(JacCeqTrans,2)==numel(Ceq)),...
            'optimlib:fmincon:WrongSizeGradNonlinEq',numel(x0),numel(Ceq));

            coder.internal.assert(isa(JacCineqTrans,'double'),'optim_codegen:fmincon:NonlconMustOutputDouble');
            coder.internal.assert(isa(JacCeqTrans,'double'),'optim_codegen:fmincon:NonlconMustOutputDouble');
            coder.internal.assert(isreal(JacCineqTrans),'optimlib:commonMsgs:ComplexIneqGradient');
            coder.internal.assert(isreal(JacCeqTrans),'optimlib:commonMsgs:ComplexEqGradient');
        else

            nVar=numel(x0);
            [Cineq,Ceq]=nonlcon(x0);


        end
        coder.internal.assert(isreal(Cineq),'optim_codegen:fmincon:NonlconMustOutputReal');
        coder.internal.assert(isreal(Ceq),'optim_codegen:fmincon:NonlconMustOutputReal');
        coder.internal.assert(isa(Cineq,'double'),'optim_codegen:fmincon:NonlconMustOutputDouble');
        coder.internal.assert(isa(Ceq,'double'),'optim_codegen:fmincon:NonlconMustOutputDouble');
        mNonlinIneq=coder.internal.indexInt(numel(Cineq));
        mNonlinEq=coder.internal.indexInt(numel(Ceq));
    else





        mNonlinIneq=coder.internal.indexInt(0);
        mNonlinEq=coder.internal.indexInt(0);
    end

end
