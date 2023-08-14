function blockNode=findNodeImpl(simlog,block)






    try
        if numel(simlog)>1
            pm_message('physmod:common:logging:sli:dataexplorer:NonScalarNode','findNode');
        end
        [isValid,nodePath]=simscape.logging.internal.findPathImpl(simlog,block);
        if isValid
            blockNode=simlog.node(nodePath);
        else
            blockNode=[];
        end
    catch ME
        ME.throwAsCaller();
    end

end
