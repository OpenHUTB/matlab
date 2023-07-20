function nlfunStruct=compileNonlinearFunction(constr,varargin)




























    nlfunStruct=compileNonlinearFunction(constr.Expr1,...
    varargin{:});


    LHS="lhsconstr";
    LHSStr=optim.internal.problemdef.compile.compileNonlinearOutput(...
    nlfunStruct,LHS);


    nlfunStruct=compileNonlinearFunction(constr.Expr2,...
    varargin{:},'ExtraParams',nlfunStruct.extraParams,'Subfun',nlfunStruct.subfun);


    RHS="rhsconstr";
    RHSStr=optim.internal.problemdef.compile.compileNonlinearOutput(...
    nlfunStruct,RHS);


    nlfunStruct.fcnBody=LHSStr+RHSStr;


    switch constr.Relation
    case '>='
        nlfunStruct.funh=RHS+" - "+LHS;
    otherwise
        nlfunStruct.funh=LHS+" - "+RHS;
    end
    nlfunStruct.singleLine=true;

end
