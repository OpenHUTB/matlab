function validateRunName(this,runName)





    validateattributes(runName,{'char'},{'nonempty','row'},'','runName',1);
    allRunNames=this.RunNames;
    if(isempty(allRunNames))
        error(message('SimulinkFixedPoint:autoscaling:noRunsExist'));
    end
    try
        validatestring(runName,allRunNames);
    catch e

        error(message('SimulinkFixedPoint:autoscaling:unrecognizedStringChoice',e.message));
    end
end