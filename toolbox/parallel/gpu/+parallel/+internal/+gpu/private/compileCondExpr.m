function[instr,compilebody]=compileCondExpr(emitter,internalState,symbols,fcnName,iR,truelabel,falselabel)







    instr='';

    compilebody=true;
    node=getCompilationNode(internalState);



    if parallel.internal.tree.isNodeFalse(node)
        compilebody=false;
        return;
    end

    [ty1,~,ro,ro2,testPtx]=compileAssignExpr(emitter,internalState,symbols,fcnName,iR);

    if isArray(ty1)
        encounteredError(internalState,message('parallel:gpu:compiler:CondexprLanguageCondNonscalar'));
    end


    tyo=coerceLogical(ty1);
    [cvt2Logical,regLogical]=castreg(emitter,internalState,tyo,ty1,ro,ro2);

    shortcircuitPtx='';
    if bodyThrowsError(internalState)
        shortcircuitPtx=checkBlockError(emitter,internalState);
        acknowledgeError(internalState);
    end

    branchreg=pGet(internalState);

    instr=[...
testPtx...
    ,cvt2Logical...
    ,shortcircuitPtx...
    ,setpredicatereg(emitter,'ne',branchreg,tyo,regLogical,'0')...
    ,conditionalBranchToLabel(emitter,branchreg,truelabel)...
    ,branchToLabel(emitter,falselabel)...
    ];

end

