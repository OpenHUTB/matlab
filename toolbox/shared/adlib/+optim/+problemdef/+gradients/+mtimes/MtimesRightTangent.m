function rightTan=MtimesRightTangent(left,right,currTangent)











    RightSize=size(right);
    IsFiniteLeft=all(isfinite(left(:)));
    IsFiniteCurrAdjoint=all(isfinite(currTangent(:)));



    if IsFiniteLeft&&IsFiniteCurrAdjoint
        nRight=RightSize(2);
        if nRight==1
            rightTan=currTangent*left';
        else
            rightTan=currTangent*kron(speye(nRight),left');
        end
    else
        rightTan=optim.problemdef.gradients.mtimes.MtimesRightTangentNonFinite(left,RightSize,currTangent);
    end
