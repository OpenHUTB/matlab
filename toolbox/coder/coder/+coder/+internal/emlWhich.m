function[whichResults,whichResultTypes]=emlWhich(aSymbol)








    useCachedSPKGRoot=false;
    [results,resultTypes]=coderapp.internal.screener.resolver.emlWhich(aSymbol,useCachedSPKGRoot);
    if nargout==0
        for idx=1:numel(results)
            fprintf('%s\t\t\t%% %s\n',results(idx),string(resultTypes(idx)));
        end
    else
        whichResults=results;
        whichResultTypes=resultTypes;
    end
end
