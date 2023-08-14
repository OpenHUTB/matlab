
function optStruct=getAnalysisOptionsFromSldv(sldvOptions,optStruct)




    if nargin<2
        optStruct=struct();
    end
    optStruct=sldv.code.internal.extractExtraOptions(sldvOptions.CodeAnalysisExtraOptions,optStruct);
    optStruct.ignoreVolatile=strcmp(sldvOptions.CodeAnalysisIgnoreVolatile,'on');
