function mlComponent=getMLComponent_hisl_0070(system,opts)

    mlComponent=Advisor.Utils.getAllMATLABFunctionBlocks(system,opts.followLinks,opts.lookUnderMask);

    if isempty(mlComponent)
        mlComponent=[];
        return
    end
    if opts.externalFile
        mFiles=Advisor.Utils.Simulink.getReferencedMatlabFiles(system);
        mlComponent=[mlComponent;num2cell(mFiles)];
    end
end