
function result=getAllRequiredInstructionSets(selectedValue)
    result={};
    if isempty(selectedValue)||strcmpi(selectedValue,'None')
        return;
    else
        result=getRequiredInstructionSetsRecursively(selectedValue);
        result=unique(result,'stable');
    end
end

function returnSets=getRequiredInstructionSetsRecursively(currentValue)
    import targetrepository.query.where
    import targetrepository.query.is
    tr=targetrepository.create();
    returnSets={};

    currentInstructioSet=tr.get('InstructionSet',where('Name',is(currentValue)));

    if isempty(currentInstructioSet)
        return;
    end


    returnSets={currentInstructioSet.Name};

    preRequisites=currentInstructioSet.Prerequisites;
    if~isempty(preRequisites)
        for i=1:length(preRequisites)
            if~ismember(preRequisites(i).Name,returnSets)
                childSets=getRequiredInstructionSetsRecursively(preRequisites(i).Name);
                returnSets=[returnSets;childSets];%#ok<AGROW>
            end
        end
    end
end