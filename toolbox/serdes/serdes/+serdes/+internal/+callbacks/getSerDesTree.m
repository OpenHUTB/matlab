






function varargout=getSerDesTree(block)
    varargout{1}=[];
    if nargout>1
        varargout{2}='';
    end



    blockParts=strsplit(block,'/');
    if size(blockParts,2)>=2



        subsystem=blockParts{2};
        if any(strcmp(subsystem,["Tx","Rx"]))
            treeName=[char(blockParts{2}),'Tree'];
            if nargout>1
                varargout{2}=treeName;
            end
            modelWorkspace=get_param(bdroot(block),'ModelWorkspace');
            if~isempty(modelWorkspace)&&modelWorkspace.hasVariable(treeName)
                varargout{1}=modelWorkspace.getVariable(treeName);
            end
        end
    end
end