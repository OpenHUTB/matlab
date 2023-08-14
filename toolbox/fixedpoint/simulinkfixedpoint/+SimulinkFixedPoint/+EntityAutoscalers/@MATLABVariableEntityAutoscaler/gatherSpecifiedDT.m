function[DTConInfo,comments,paramName]=gatherSpecifiedDT(~,variableIdentifier,varargin)











    paramName='';
    comments={};


    masterInference=variableIdentifier.MasterInferenceReport;
    [compiledDT,~]=fixed.internal.mxInfoToDataTypeString(...
    variableIdentifier.MxInfoID,...
    masterInference.MxInfos,...
    masterInference.MxArrays);

    DTConInfo=SimulinkFixedPoint.DTContainerInfo(compiledDT,variableIdentifier.getMATLABFunctionBlock);

end