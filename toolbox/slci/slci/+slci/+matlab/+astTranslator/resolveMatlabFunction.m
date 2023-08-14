


function cObj=resolveMatlabFunction(mtreeNode,astObj)

    [cObj,resolved]=createMatlabFunction(mtreeNode,astObj);
    if~resolved

        AstClassName='slci.ast.SFAstUnsupported';
        cmd=['cObj = ',AstClassName,' (mtreeNode, astObj);'];
        eval(cmd);
    end

end



function[cObj,resolved]=createMatlabFunction(node,astObj)
    cObj=[];
    resolved=true;
    assert(any(strcmp(node.kind,{'CALL','LP'})),'Invalid function node');
    ch1=node.Left;
    assert(strcmpi(ch1.kind,'ID'));

    fname=ch1.string;
    if strcmpi(fname,'cross')
        cObj=slci.ast.SFAstCross(node,astObj);
    elseif strcmpi(fname,'dot')
        cObj=slci.ast.SFAstDotProduct(node,astObj);
    elseif strcmpi(fname,'mean')
        cObj=slci.ast.SFAstMean(node,astObj);
    elseif strcmpi(fname,'deg2rad')
        cObj=slci.ast.SFAstDeg2Rad(node,astObj);
    elseif strcmpi(fname,'rad2deg')
        cObj=slci.ast.SFAstRad2Deg(node,astObj);
    else
        resolved=false;
    end
end