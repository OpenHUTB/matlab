function[isSubset,unfoundLhs]=isInstructionSetEqualOrSubset(lhsInstructions,rhsInstructions)

    lhsLength=length(lhsInstructions);
    rhsLength=length(rhsInstructions);

    unfoundIdx=0;
    unfoundLhs={};
    isSubset=true;
    for i=1:lhsLength
        thisLhs=lhsInstructions(i);

        if skipInstruction(thisLhs)
            continue;
        end

        found=false;
        for j=1:rhsLength
            if thisLhs.isequal(rhsInstructions(j))
                found=true;
                break;
            end
        end

        if~found
            unfoundIdx=unfoundIdx+1;
            isSubset=false;
            unfoundLhs{unfoundIdx}=thisLhs;%#ok<AGROW>
        end
    end
end

function skip=skipInstruction(instruction)
    SkipSet=["eq","ne","lt","le","gt","ge"];
    skip=any(SkipSet==instruction.Intrinsic);
end