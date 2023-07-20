function visitOperatorStaticAssign(visitor,~,Node)





    [rhsType,rhsValue,rhsSz,rhsCanAD]=popChild(visitor,2);


    LHS=Node.ExprLeft;
    pushNode(visitor,LHS,rhsType,rhsValue);
    pushNodePties(visitor,LHS,rhsSz,rhsCanAD);


    lhsSz=LHS.Size;
    if any(lhsSz)&&~all(lhsSz==1)
        if~isequal(lhsSz,rhsSz)




            error('shared_adlib:static:SizeChangeDetected','The size of the LHS must not change');
        end
    else

        LHS.Size=rhsSz;
    end


    LHS.Value=rhsValue;

end
