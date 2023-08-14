function determineWarnings(this,runObj)




    allResults=runObj.dataTypeGroupInterface.nodes.values;


    for rIndex=1:numel(allResults)
        allResults{rIndex}.setAlert('');
    end





    FPTMATLABFunctionBlockFloat2Fixed=slfeature('FPTMATLABFunctionBlockFloat2Fixed');
    if FPTMATLABFunctionBlockFloat2Fixed
        sudID=fxptds.SimulinkIdentifier(get_param(this.sysToScaleName,'Object'));
        SimulinkFixedPoint.AutoscalerUtils.applyProposedTypesForMLFBS(allResults,runObj,sudID);
    end

    allGroups=runObj.dataTypeGroupInterface.getGroups();




    for groupIndex=1:length(allGroups)
        allGroups{groupIndex}.determineWarnings(this.proposalSettings);
    end

end


