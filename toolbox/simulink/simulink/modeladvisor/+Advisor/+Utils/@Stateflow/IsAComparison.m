function booleanResult=IsAComparison(ast)


    switch(class(ast))
    case 'Stateflow.Ast.IsEqual'
        booleanResult=true;
    case 'Stateflow.Ast.IsNotEqual'
        booleanResult=true;
    case 'Stateflow.Ast.NegEqual'
        booleanResult=true;
    case 'Stateflow.Ast.LesserThanGreaterThan'
        booleanResult=true;
    case 'Stateflow.Ast.GreaterThanOrEqual'
        booleanResult=true;
    case 'Stateflow.Ast.LesserThanOrEqual'
        booleanResult=true;
    case 'Stateflow.Ast.LesserThan'
        booleanResult=true;
    case 'Stateflow.Ast.GreaterThan'
        booleanResult=true;
    case 'Stateflow.Ast.OldLesserThan'
        booleanResult=true;
    case 'Stateflow.Ast.OldLesserThanOrEqual'
        booleanResult=true;
    case 'Stateflow.Ast.OldGreaterThan'
        booleanResult=true;
    case 'Stateflow.Ast.OldGreaterThanOrEqual'
        booleanResult=true;
    case 'Stateflow.Ast.BitAnd'
        booleanResult=true;
    case 'Stateflow.Ast.BitOr'
        booleanResult=true;
    case 'Stateflow.Ast.BitXor'
        booleanResult=true;
    otherwise
        booleanResult=false;
    end
end