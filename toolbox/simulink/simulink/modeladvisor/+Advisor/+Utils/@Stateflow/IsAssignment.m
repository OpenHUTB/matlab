function booleanResult=IsAssignment(ast)


    switch(class(ast))
    case 'Stateflow.Ast.MinusAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.ColonAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.PlusAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.TimesAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.DivAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.ModulusAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.AndAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.OrAssignment'
        booleanResult=true;
    case 'Stateflow.Ast.XorAssignment'
        booleanResult=true;
    otherwise
        booleanResult=false;
    end
end