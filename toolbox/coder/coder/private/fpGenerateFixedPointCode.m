

function[messages,success,errorMessage,inference,summary,isVarLoggableInfo]=fpGenerateFixedPointCode(data,entryPoint,prebuildChecksum)
    try
        [success,report,summary,isVarLoggableInfo,messages,errorMessage]=coderprivate.Float2FixedManager.instance.generateFixedPointCode(data,entryPoint);
        inference=flattenInferenceReportForJava(report);
        manager=coder.internal.F2FGuiCallbackManager.getInstance();
        manager.ConversionOutput={messages,success,errorMessage,inference,summary,isVarLoggableInfo};
        manager.Checksum=prebuildChecksum;

        if isfield(summary,'data')
            summary=rmfield(summary,'data');
        end
    catch ex
        throwAsCaller(ex);
    end
end
