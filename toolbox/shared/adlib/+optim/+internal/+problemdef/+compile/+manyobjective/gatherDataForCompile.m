function[objectives,idxObjectives,numObjectives,sizeOfObjectives]=...
    gatherDataForCompile(prob)




















    ObjectiveName=prob.ObjectivePtyName;


    objectives=prob.(ObjectiveName);


    if isstruct(objectives)
        objectives=struct2cell(objectives);
        numEqnObjects=numel(objectives);
        islinear=false(numEqnObjects,1);
        isquadratic=false(numEqnObjects,1);
        sizeOfObjectives=zeros(numEqnObjects,1);
        for k=1:numEqnObjects
            if~isempty(objectives{k})
                islinear(k)=isLinear(objectives{k});
                isquadratic(k)=isQuadratic(objectives{k});
                sizeOfObjectives(k)=numel(objectives{k});
            end
        end
    else
        objectives={prob.(ObjectiveName)};
        islinear=isLinear(objectives{1});
        isquadratic=isQuadratic(objectives{1});
        sizeOfObjectives=numel(objectives{1});
    end


    idxObjectives.Linear=find(islinear);

    idxObjectives.Quadratic=find(isquadratic);

    idxObjectives.Nonlinear=find(~islinear&~isquadratic);


    numObjectives.Linear=sum(sizeOfObjectives(idxObjectives.Linear));
    numObjectives.Quadratic=sum(sizeOfObjectives(idxObjectives.Quadratic));
    numObjectives.Nonlinear=sum(sizeOfObjectives(idxObjectives.Nonlinear));

end