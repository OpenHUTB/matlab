function varargout=explore(node,sourcePath,varName)















    if(simscape.logging.internal.newResultsExplorer)
        simscapeResultsExplorer(node,sourcePath,varName);
    else

        if numel(node)>1
            pm_message('physmod:common:logging:sli:dataexplorer:NonScalarNode','explore');
        end

        explorerHandle=simscape.logging.internal.linkedExplorerHandle();

        if~isempty(explorerHandle)&&explorerHandle.isvalid










            if isempty(sourcePath)






                ud=get(explorerHandle,'UserData');
                [~,sourcePath]=simscape.logging.internal.getSelectedNodes(...
                ud.tree,ud.node);
            end


            simscape.logging.internal.refresh(explorerHandle,node,varName,...
            sourcePath);
        else


            explorerHandle=simscape.logging.internal.new(node,sourcePath,varName);
        end

        if~isempty(explorerHandle)&&explorerHandle.isvalid
            figure(explorerHandle);
        end
    end
end
