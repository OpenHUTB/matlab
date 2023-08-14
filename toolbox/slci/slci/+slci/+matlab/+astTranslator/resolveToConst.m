





function[resolved,cObj]=resolveToConst(node,astObj)

    resolved=false;
    cObj=[];

    assert(isa(astObj.ParentBlock(),'slci.simulink.IfBlock'),...
    ['Invalid parent block ',class(astObj.ParentBlock())]);

    if any(strcmpi(node.kind,{'CALL','LP'}))
        subscriptStr=tree2str(node);
        id=node.Left;
        [wsval,resolved]=astObj.ParentBlock().readSubscriptStr(...
        id.string,...
        subscriptStr);
    elseif strcmpi(node.kind,'ID')
        [wsval,resolved]=astObj.ParentBlock().readIdentifier(node.string);
    end

    if resolved
        if isa(wsval,'numeric')&&isscalar(wsval)

            cObj=createNumericAst(node,wsval,astObj);
        else

            resolved=false;
        end
    end

end


function cObj=createNumericAst(node,value,astObj)
    assert(any(strcmpi(node.kind,{'ID','CALL','LP'})));
    assert(isnumeric(value)&&isscalar(value));
    cObj=slci.ast.SFAstNum(node,astObj);
end
