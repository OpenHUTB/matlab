function exploreForSlToolstrip(log,blkHandle,logName)















    try


        [isValid,sourcePath]=simscape.logging.findPath(log,blkHandle);
    catch ME
        pm_error('physmod:common:logging:sli:dataexplorer:InvalidSimulinkHandle');
    end

    if(isValid)

        simscape.logging.internal.explore(log,sourcePath,logName);
    else
        if(simscape.logging.internal.newResultsExplorer)

            simscapeResultsExplorer(log,sourcePath,logName);
        else
            explorerHandle=simscape.logging.internal.linkedExplorerHandle();
            if~isempty(explorerHandle)&&explorerHandle.isvalid





                simscape.logging.internal.refresh(explorerHandle,log,logName,'');
            else




                simscape.logging.internal.new(log,'',logName);
            end
        end
    end
end
