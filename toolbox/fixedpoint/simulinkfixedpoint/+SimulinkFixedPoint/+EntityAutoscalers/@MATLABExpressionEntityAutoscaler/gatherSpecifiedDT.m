function[DTConInfo,comments,paramName]=gatherSpecifiedDT(~,expressionIdentifier,varargin)














    paramName='';
    comments={};


    masterInference=expressionIdentifier.MasterInferenceReport;
    [compiledDT,~]=fixed.internal.mxInfoToDataTypeString(...
    expressionIdentifier.MxInfoID,...
    masterInference.MxInfos,...
    masterInference.MxArrays);


    DTConInfo=SimulinkFixedPoint.DTContainerInfo(compiledDT,expressionIdentifier.getMATLABFunctionBlock);
end
