function[baselineSigID,compareToSigID,diffSigID,tolSigID,...
    tolLowerSigID,tolUpperSigID,diffTolLowerSigID,diffTolUpperSigID,...
    compMinusBaseSigID,passSigID,failureRegionSigID]=...
    getSignalComparisonResultByType(...
    this,comparisonSignalID)
    sigChildren=this.getSignalChildren(comparisonSignalID);

    baselineSigID=[];
    compareToSigID=[];
    diffSigID=[];
    tolSigID=[];
    tolLowerSigID=[];
    tolUpperSigID=[];
    diffTolLowerSigID=[];
    diffTolUpperSigID=[];
    compMinusBaseSigID=[];
    passSigID=[];
    failureRegionSigID=[];
    for i=1:length(sigChildren)
        sourceType=this.getSignalSourceType(sigChildren(i));
        if strcmpi(sourceType,'baseline')
            baselineSigID=sigChildren(i);
        elseif strcmpi(sourceType,'compare_to')
            compareToSigID=sigChildren(i);
        elseif strcmpi(sourceType,'difference')
            diffSigID=sigChildren(i);
        elseif strcmpi(sourceType,'tolerance')
            tolSigID=sigChildren(i);
        elseif strcmpi(sourceType,'tolLower')
            tolLowerSigID=sigChildren(i);
        elseif strcmpi(sourceType,'tolUpper')
            tolUpperSigID=sigChildren(i);
        elseif strcmpi(sourceType,'diffTolLower')
            diffTolLowerSigID=sigChildren(i);
        elseif strcmpi(sourceType,'diffTolUpper')
            diffTolUpperSigID=sigChildren(i);
        elseif strcmpi(sourceType,'comparedToMinusBaseline')
            compMinusBaseSigID=sigChildren(i);
        elseif strcmpi(sourceType,'pass')
            passSigID=sigChildren(i);
        elseif strcmpi(sourceType,'failureRegion')
            failureRegionSigID=sigChildren(i);
        end
    end
end