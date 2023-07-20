


function cObj=createSFFunctionCall(mtreeNode,astObj)%#ok

    assert(any(strcmp(mtreeNode.kind,{'CALL','LP'})),...
    'Invalid function node');

    AstClassName=['slci.ast.'...
    ,slci.matlab.astTranslator.getAstClassForMNode('SFCALL')];
    cmd=['cObj = ',AstClassName,' (mtreeNode, astObj);'];
    eval(cmd);

end
