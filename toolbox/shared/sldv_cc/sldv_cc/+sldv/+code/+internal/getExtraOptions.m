
function options=getExtraOptions()
    testComp=sldvprivate('sldvGetTestComponent');
    sldvOptions=testComp.activeSettings;
    options=struct();
    options=sldv.code.internal.extractExtraOptions(sldvOptions.CodeAnalysisExtraOptions,options);
end
