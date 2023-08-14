function varDesc=getVarDesc(node,functionTypeInfo,treeName)







    if nargin<3
        treeName='treeAttributes';
    end

    varDesc=functionTypeInfo.(treeName)(node).VariableDescriptor;
    if isempty(varDesc)
        varDesc=internal.mtree.analysis.VariableDescriptor(...
        'INDETERMINABLE_IF_CONST',...
        internal.mtree.type.UnknownType);
    end
end
