function postMakeActions(buildResults,lDispHook,...
    lRTWVerbose,modelName)





    if~isempty(buildResults)&&buildResults.LegacyDownload



        downloadSuccess=buildResults.LegacyTmfMacros.DOWNLOAD_SUCCESS;
        if isempty(downloadSuccess)
            downloadSuccess='### Downloaded';
        elseif downloadSuccess(1)=='['
            downloadSuccess=locEvalMakeVar(downloadSuccess,...
            modelName,...
            'DOWNLOAD_SUCCESS');
        end

        downloadError=buildResults.LegacyTmfMacros.DOWNLOAD_ERROR;
        if isempty(downloadError)
            downloadError=DAStudio.message('RTW:buildProcess:GenericDownloadError',modelName);
        elseif downloadError(1)=='['
            downloadError=locEvalMakeVar(downloadError,...
            modelName,...
            'DOWNLOAD_ERROR');
        end

        makeCmd=[buildResults.EvaluatedMakeCommand,' download '];
        feval(lDispHook{:},['### Downloading ',modelName,': ',makeCmd]);

        makefileVerboseOverride=false;
        makefileVerboseVal=buildResults.LegacyTmfMacros.VERBOSE_BUILD_OFF_TREATMENT;
        if(~isempty(makefileVerboseVal)&&...
            strcmp(makefileVerboseVal,'PRINT_OUTPUT_ALWAYS'))
            makefileVerboseOverride=true;
        end

        if lRTWVerbose||makefileVerboseOverride
            echoArg={'-echo'};
        else
            echoArg={};
        end
        if isunix

            status=unix(makeCmd,echoArg{:});
            if status~=0
                error('RTW:buildProcess:downloadError',downloadError);
            end
        elseif ispc
            [~,result]=dos(makeCmd,echoArg{:});

            if~contains(result,downloadSuccess)
                if~lRTWVerbose&&~makefileVerboseOverride
                    feval(lDispHook{:},result);
                end
                error('RTW:buildProcess:downloadError',downloadError);
            end
        else
            DAStudio.error('RTW:buildProcess:unhandledSystemType');
        end
    end
end














function rc=locEvalMakeVar(inp,modelName,makeVar)%#ok<INUSL>

    try
        rc=eval(inp);
    catch exc
        DAStudio.error('RTW:buildProcess:badTMFMakeVar',...
        makeVar,inp,exc.message);
    end
end

