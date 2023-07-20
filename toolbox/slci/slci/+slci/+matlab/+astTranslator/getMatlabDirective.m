







function[flag,directive]=getMatlabDirective(mlToken,aParent)

    flag=false;
    directive=[];
    args={};

    if(strcmp(mlToken.kind,'SUBSCR')||strcmp(mlToken.kind,'LP'))...
        &&strcmp(mlToken.Left.kind,'DOT')
        directive=mlToken.Left;
        if~isempty(mlToken.Right)
            args=slci.mlutil.getListNodes(mlToken.Right);
        end
    elseif strcmp(mlToken.kind,'DOT')
        directive=mlToken;
        args={};
    else
        return;
    end


    assert(strcmp(directive.kind,'DOT'));
    package=directive.Left;
    if strcmp(package.kind,'ID')&&strcmp(package.string,'coder')
        fcn=directive.Right;

        [flag,directive]=readFieldName(fcn,mlToken,args,aParent);
    elseif strcmp(package.kind,'DOT')

        if strcmp(package.Left.kind,'ID')...
            &&strcmp(package.Left.string,'slci')...
            &&strcmp(package.Right.kind,'FIELD')...
            &&strcmp(package.Right.string,'mlutil')
            fcn=directive.Right;

            if strcmp(fcn.kind,'FIELD')&&strcmp(fcn.string,'reviewmode')
                flag=true;
                directive=slci.ast.SFAstManualReview(mlToken,...
                aParent);
            end
        end
    end
end


function[flag,directive]=readFieldName(fcn,mlToken,args,aParent)

    assert(strcmp(fcn.kind,'FIELD'));
    switch fcn.string

    case 'inline'
        flag=true;
        directive=slci.ast.SFAstInline(mlToken,...
        args,...
        aParent);

    case 'nullcopy'
        flag=true;
        directive=slci.ast.SFAstNullCopy(mlToken,...
        args,...
        aParent);

    case 'const'
        flag=true;
        directive=slci.ast.SFAstCoderConst(mlToken,...
        aParent);
    case 'target'
        flag=true;
        directive=slci.ast.SFAstCoderTarget(mlToken,...
        args,...
        aParent);

    case 'ceval'
        flag=true;
        directive=slci.ast.SFAstCEval(mlToken,...
        args,...
        aParent);

    case 'rref'
        flag=true;
        directive=slci.ast.SFAstRRef(mlToken,...
        args,...
        aParent);
    case 'wref'
        flag=true;
        directive=slci.ast.SFAstWRef(mlToken,...
        args,...
        aParent);
    case 'ref'
        flag=true;
        directive=slci.ast.SFAstRef(mlToken,...
        args,...
        aParent);
    case 'cinclude'
        flag=true;
        directive=slci.ast.SFAstCInclude(mlToken,...
        args,...
        aParent);
    otherwise
        flag=false;
        directive=[];
    end

end
