
function nodeDescriptor=cellToNodeDescriptor(descriptorCell)




    if isempty(descriptorCell)


        nodeDescriptor=internal.mtree.analysis.VariableDescriptor(...
        'INDETERMINABLE_IF_CONST',internal.mtree.type.Void);
    elseif numel(descriptorCell)==1


        nodeDescriptor=descriptorCell{1};
    else

        nodeDescriptor=internal.mtree.analysis.NodeDescriptor(descriptorCell);
    end
end
