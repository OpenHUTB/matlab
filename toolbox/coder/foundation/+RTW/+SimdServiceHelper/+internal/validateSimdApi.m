function validateSimdApi(simdApi)
    numFcn=length(simdApi.Functions);
    for i=1:numFcn
        RTW.SimdServiceHelper.internal.validateSimdFunction(simdApi.Functions(i),simdApi);
    end
end