%#codegen

function[data,dataInfo,dataExprIdMapping,numLoggedExpr]=customFetchLoggedData()
    coder.extrinsic('custom_logger_lib');
    coder.allowpcode('plain');
    [data,dataInfo]=custom_mex_logger();
    numLoggedExpr=length(dataInfo)-1;
    dataExprIdMapping=coder.const(@custom_logger_lib,'fetchMappingInfo');
end