function globalIOAnalysis(modelName)



    slfeature('CCallerGlobalIO',1);

    validateattributes(modelName,{'char','string'},{'scalartext'});
    hMDL=get_param(modelName,'Handle');
    slcc('performGlobalIOAnalysis',hMDL);

    cCallerBlkH=Simulink.findBlocksOfType(modelName,'CCaller');
    for idx=1:length(cCallerBlkH)
        try

            if isempty(get_param(cCallerBlkH(idx),'ReferenceBlock'))
                get_param(cCallerBlkH(idx),'FunctionPortSpecification');
            end
        catch ME
            blkPath=getfullname(cCallerBlkH(idx));
            warning(sprintf(['Block Path: ',blkPath,'\nMessage: ',ME.message]));%#ok
        end
    end
    slcc('CCallerGlobalIOBlockRefresh',hMDL);
end