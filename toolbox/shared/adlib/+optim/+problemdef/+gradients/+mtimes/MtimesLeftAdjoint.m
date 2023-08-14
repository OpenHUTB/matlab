function leftJac=MtimesLeftAdjoint(leftSize,right,currAdjoint)











    IsFiniteRight=all(isfinite(right(:)));
    IsFiniteCurrAdjoint=all(isfinite(currAdjoint(:)));



    if IsFiniteRight&&IsFiniteCurrAdjoint
        nLeft=leftSize(1);
        if nLeft==1
            leftJac=right*currAdjoint;
        else
            leftJac=kron(right,speye(nLeft))*currAdjoint;
        end
    else
        leftJac=optim.problemdef.gradients.mtimes.MtimesLeftAdjointNonFinite(leftSize,right,currAdjoint);
    end
