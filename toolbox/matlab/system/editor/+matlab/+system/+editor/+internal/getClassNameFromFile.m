function candidateName=getClassNameFromFile(filePath)





    [candidatePath,candidateName]=fileparts(filePath);
    [candidatePath,candidatePackage]=fileparts(candidatePath);


    if(length(candidatePackage)>1)&&strcmp(candidatePackage(1),'@')&&strcmp(candidatePackage(2:end),candidateName)
        [candidatePath,candidatePackage]=fileparts(candidatePath);
    end


    while~isempty(candidatePackage)&&strcmp(candidatePackage(1),'+')
        candidateName=[candidatePackage(2:end),'.',candidateName];%#ok<AGROW>
        [candidatePath,candidatePackage]=fileparts(candidatePath);
    end
end