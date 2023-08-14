function[nlfunStruct,jacStruct]=compileForwardAD(constr,varargin)






















































    [nlfunStruct,jacStruct]=compileForwardAD(constr.Expr1,...
    varargin{:},'Reset',false);


    LHS="lhsconstr";
    [Expr1Str,LHS1Str]=optim.internal.problemdef.compile.compileNonlinearOutput(...
    nlfunStruct,LHS);


    LHSgrad="lhsconstrgrad";
    Grad1Str=optim.internal.problemdef.compile.compileNonlinearOutput(...
    jacStruct,LHSgrad);



    Grad1Str=Grad1Str+LHS1Str;


    HelperNlfunLHSLocs=nlfunStruct.pkgDepends;
    HelperJacLHSLocs=jacStruct.pkgDepends;



    [nlfunStruct,jacStruct]=compileForwardAD(constr.Expr2,...
    varargin{:},'ExtraParams',nlfunStruct.extraParams,'Subfun',nlfunStruct.subfun,...
    'Reset',false);


    RHS="rhsconstr";
    [Expr2Str,LHS2Str]=optim.internal.problemdef.compile.compileNonlinearOutput(...
    nlfunStruct,RHS);


    RHSgrad="rhsconstrgrad";
    Grad2Str=optim.internal.problemdef.compile.compileNonlinearOutput(...
    jacStruct,RHSgrad);



    Grad2Str=Grad2Str+LHS2Str;


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
