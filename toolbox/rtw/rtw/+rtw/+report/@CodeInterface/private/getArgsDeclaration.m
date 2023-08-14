

function argDecl=getArgsDeclaration(fcnPrototype)

    argDecl='';
    argsLen=length(fcnPrototype.Arguments);
    if argsLen==0
        argDecl='void';
        return
    else
        for argIter=1:argsLen
            currargDecl=getVariableDeclaration(fcnPrototype.Arguments(argIter));
            if isempty(argDecl)
                argDecl=currargDecl;
            else
                argDecl=[argDecl,', ',currargDecl];%#ok<AGROW>
            end
        end
    end

end
