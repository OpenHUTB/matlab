function rightJac=MtimesRightAdjoint(left,rightSize,currAdjoint)











    IsFiniteLeft=all(isfinite(left(:)));
    IsFiniteCurrAdjoint=all(isfinite(currAdjoint(:)));



    if IsFiniteLeft&&IsFiniteCurrAdjoint
        nRight=rightSize(2);
        if nRight==1
            rightJac=left'*currAdjoint;
        else
            rightJac=kron(speye(nRight),left')*currAdjoint;
        end
    else
        rightJac=optim.problemdef.gradients.mtimes.MtimesRightAdjointNonFinite(left,rightSize,currAdjoint);
    end

