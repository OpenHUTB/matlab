function newComp=getAssignmentComp(hN,hInputSignals,hOutputSignals,oneBasedIdx,...
    ndims,idxParamArray,idxOptionsArray,...
    outputSizeArray,compName)


    narginchk(9,9);
    newComp=hN.addComponent2(...
    'kind','assignment_comp',...
    'Name',compName,...
    'InputSignals',hInputSignals,...
    'OutputSignals',hOutputSignals,...
    'IndexMode',oneBasedIdx,...
    'NumberOfDimensions',ndims,...
    'IndexParamArray',idxParamArray,...
    'IndexOptionArray',idxOptionsArray,...
    'OutputSizeArray',outputSizeArray);
end
