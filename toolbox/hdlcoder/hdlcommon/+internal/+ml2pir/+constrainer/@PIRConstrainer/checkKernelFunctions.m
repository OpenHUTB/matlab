function checkKernelFunctions(this,callee,topNode,fcnInfo)






    persistentVarNames=fcnInfo.persistentVarNames;
    for i=1:numel(persistentVarNames)
        this.addMessage(topNode,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:HDLfunPersistentUnsupported',...
        persistentVarNames{i},...
        fcnInfo.functionName,...
        topNode.tree2str,...
        callee);
    end




    subscrNodes=mtfind(fcnInfo.tree.Body.Full,'Kind','SUBSCR');
    subscrIdxs=subscrNodes.indices;
    for i=1:numel(subscrIdxs)
        nd=subscrNodes.select(subscrIdxs(i));
        if ismember(nd.Left.tree2str,{'hdl.npufun','hdl.iteratorfun'})
            this.addMessage(topNode,...
            internal.mtree.MessageType.Error,...
            'hdlcommon:matlab2dataflow:HDLfunNestedUnsupported',...
            nd.tree2str,...
            fcnInfo.functionName,...
            topNode.tree2str,...
            nd.Left.tree2str);
        end
    end


    for i=1:numel(fcnInfo.callSites)


        checkKernelFunctions(this,callee,topNode,fcnInfo.callSites{i}{2});
    end
end
