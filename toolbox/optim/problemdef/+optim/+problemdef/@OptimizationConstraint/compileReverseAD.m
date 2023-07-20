function[nlfunStruct,jacStruct]=compileReverseAD(constr,varargin)
























































    [nlfunStruct,jacStruct]=compileReverseAD(constr.Expr1,...
    varargin{:},'Reset',false);


    LHS="lhsconstr";
    Expr1Str=optim.internal.problemdef.compile.compileNonlinearOutput(...
    nlfunStruct,LHS);


    LHSgrad="lhsconstrgrad";
    Grad1Str=optim.internal.problemdef.compile.compileNonlinearOutput(...
    jacStruct,LHSgrad);


    HelperNlfunLHSLocs=nlfunStruct.pkgDepends;
    HelperJacLHSLocs=jacStruct.pkgDepends;



    [nlfunStruct,jacStruct]=compileReverseAD(constr.Expr2,...
    varargin{:},'ExtraParams',jacStruct.extraParams,'Subfun',nlfunStruct.subfun,...
    'Reset',false);


    RHS="rhsconstr";
    Expr2Str=optim.internal.problemdef.compile.compileNonlinearOutput(...
    nlfunStruct,RHS);


    RHSgrad="rhsconstrgrad";
    Grad2Str=optim.internal.problemdef.compile.compileNonlinearOutput(...
    jacStruct,RHSgrad);


    nlfunStruct.fcnBody=Expr1Str+Expr2Str;


    jacStruct.fcnBody=Grad1Str+Grad2Str;


    nlfunStruct.pkgDepends=[HelperNlfunLHSLocs,nlfunStruct.pkgDepends];
    jacStruct.pkgDepends=[HelperJacLHSLocs,jacStruct.pkgDepends];


    switch constr.Relation
    case '>='
        nlfunStruct.funh=RHS+" - "+LHS;
        jacStruct.funh=RHSgrad+" - "+LHSgrad;
    otherwise
        nlfunStruct.funh=LHS+" - "+RHS;
        jacStruct.funh=LHSgrad+" - "+RHSgrad;
    end

end
