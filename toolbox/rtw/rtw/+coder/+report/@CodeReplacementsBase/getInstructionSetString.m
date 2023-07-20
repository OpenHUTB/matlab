function instructionSetString=getInstructionSetString(obj)

    instructionSetString=Advisor.List;
    instructionSetString.setType('Bulleted');
    if~isempty(obj.InstructionSetExtensions)&&~ismember('None',obj.InstructionSetExtensions)
        instructionSets=obj.InstructionSetExtensions;
        for i=1:length(instructionSets)

            instructionSetString.addItem(instructionSets{i});
        end
    end

end