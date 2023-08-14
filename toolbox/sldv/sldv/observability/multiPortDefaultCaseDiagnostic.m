function isErr=multiPortDefaultCaseDiagnostic(blockH)





    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    isErr=coder.const(sldvprivate('getDiagnosticForDefaultCase',blockH));
end
