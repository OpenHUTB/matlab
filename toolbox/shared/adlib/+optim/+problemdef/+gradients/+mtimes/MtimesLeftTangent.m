function leftTan=MtimesLeftTangent(left,right,currTangent)











    LeftSize=size(left);
    IsFiniteRight=all(isfinite(right(:)));
    IsFiniteCurrTangent=all(isfinite(currTangent(:)));



    if IsFiniteRight&&IsFiniteCurrTangent
        nLeft=LeftSize(1);
        if nLeft==1
            leftTan=currTangent*right;
        else
            leftTan=currTangent*kron(right,speye(nLeft));
        end
    else
        leftTan=optim.problemdef.gradients.mtimes.MtimesLeftTangentNonFinite(LeftSize,right,currTangent);
    end
