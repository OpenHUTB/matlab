function instructionVector=generateInstructionsFromSimdTable(aCrlTable)
    instructionVector=[];
    idx=1;
    numEnt=length(aCrlTable.AllEntries);
    for i=1:numEnt
        instruction=RTW.InstructionSetChecker.generateInstruction(aCrlTable.AllEntries(i));
        if~isempty(instruction)
            if idx==1
                instructionVector=instruction;
            else
                instructionVector(idx)=instruction;%#ok<AGROW>
            end
            idx=idx+1;
        end
    end
end