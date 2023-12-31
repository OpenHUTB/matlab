
function astClass=getAstClassForMNode(mnode)

    persistent astClassMap;
    if isempty(astClassMap)
        mNodesToAst={'ID','SFAstIdentifier';...
        'INT','SFAstNum';...
        'DOUBLE','SFAstNum';...
        'SUBSCR','SFAstArray';...
        'LT','SFAstLesserThan';...
        'GT','SFAstGreaterThan';...
        'LE','SFAstLesserThanOrEqual';...
        'GE','SFAstGreaterThanOrEqual';...
        'EQ','SFAstIsEqual';...
        'NE','SFAstIsNotEqual';...
        'AND','SFAstLogicalAnd';...
        'OR','SFAstLogicalOr';...
        'NOT','SFAstNot';...
        'UMINUS','SFAstUminus';...
        'UPLUS','SFAstUplus';...
        'CONCATENATELB','SFAstConcatenateLB';...
        'LC','SFAstLC';...
        'ROW','SFAstRow';...
        'EQUALS','SFAstEqualAssignment';...
        'FUNCTION','SFAstMatlabFunctionDef';...
        'TRANS','SFAstCTranspose';...
        'DOTTRANS','SFAstDotTranspose';...
        'PLUS','SFAstPlus';...
        'MINUS','SFAstMinus';...
        'MUL','SFAstMul';...
        'DOTMUL','SFAstTimes';...
        'EXP','SFAstPow';...
        'DOTEXP','SFAstDotPow';...
        'LDIV','SFAstLDiv';...
        'DIV','SFAstDivide';...
        'DOTLDIV','SFAstDotLDiv';...
        'DOTDIV','SFAstDotDiv';...
        'OROR','SFAstOrOr';...
        'ANDAND','SFAstAndAnd';...
        'COLON','SFAstColon';...
        'IF','SFAstIf';...
        'IFHEAD','SFAstIfHead';...
        'ELSEIF','SFAstElseIf';...
        'ELSE','SFAstElse';...
        'SWITCH','SFAstSwitch';...
        'CASE','SFAstCase';...
        'OTHERWISE','SFAstOtherwise';...
        'RETURN','SFAstReturn';...
        'CHARVECTOR','SFAstString';...
        'CALL','SFAstMatlabFunctionCall';...
        'TILDE','SFAstTilde';...
        'FOR','SFAstFor';...
        'DOT','SFAstDot';...
        'WHILE','SFAstWhile';...
        'BREAK','SFAstBreak';...
        'CONTINUE','SFAstContinue';...
        };
        astClassMap=containers.Map(mNodesToAst(:,1),mNodesToAst(:,2));
    end

    persistent stateflowAstClassMap;
    if isempty(stateflowAstClassMap)
        mNodesToAst={'SFCALL','SFAstMatlabFunctionCallForStateflow';...
        };
        stateflowAstClassMap=containers.Map(mNodesToAst(:,1),mNodesToAst(:,2));
    end

    if isKey(astClassMap,mnode)
        astClass=astClassMap(mnode);
    elseif isKey(stateflowAstClassMap,mnode)
        astClass=stateflowAstClassMap(mnode);
    else
        astClass='SFAstUnsupported';
    end

end
