



function[report,newMessages]=processPotentialDifferences(report)

    potentialDifferences=extractPotentialDifferences(report);

    if isempty(potentialDifferences)
        newMessages=[];
        return;
    end

    newMessages=propagateLocations(potentialDifferences,report);