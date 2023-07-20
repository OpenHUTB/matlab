function isSimCodegen=IsModelSimInCodeGenTLC







    isSimCodegen=false;
    if exist('isSimulinkStarted','builtin')&&isSimulinkStarted
        modelCodegenMgr=...
        coder.internal.ModelCodegenMgr.getInstance(bdroot);
        if~isempty(modelCodegenMgr)
            tlcName=modelCodegenMgr.SystemTargetFilename;
            if contains(tlcName,'raccel.tlc')...
                ||contains(tlcName,'modelrefsim.tlc')
                isSimCodegen=true;
                return;
            end
        end
    end
end