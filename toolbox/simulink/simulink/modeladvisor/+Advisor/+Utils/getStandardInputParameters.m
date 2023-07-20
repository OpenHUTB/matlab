function parameterObj=getStandardInputParameters(mdladvObj,parameterID)




    switch parameterID
    case 'find_system.FollowLinks'
        parameterObj=mdladvObj.getInputParameterByName('Follow links');
    case 'find_system.LookUnderMasks'
        parameterObj=mdladvObj.getInputParameterByName('Look under masks');
    otherwise
        DAStudio.error('ModelAdvisor:engine:InvalidInputParameterName',parameterID);
    end
end