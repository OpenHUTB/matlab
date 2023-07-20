function expandedDescriptors=expandDescriptors(descriptors)











    descCount=numel(descriptors);
    for ii=1:numel(descriptors)
        varDesc=descriptors{ii};
        if isa(varDesc,'internal.mtree.analysis.NodeDescriptor')
            descCount=descCount+varDesc.getLength-1;
        end
    end

    if descCount==numel(descriptors)

        expandedDescriptors=descriptors;
    else
        expandedDescriptors=cell(1,descCount);
        descIdx=1;

        for ii=1:numel(descriptors)
            varDesc=descriptors{ii};
            if~isa(varDesc,'internal.mtree.analysis.NodeDescriptor')
                expandedDescriptors{descIdx}=varDesc;
                descIdx=descIdx+1;
            else

                for jj=1:varDesc.getLength
                    expandedDescriptors{descIdx}=varDesc.getVarDesc(jj);
                    descIdx=descIdx+1;
                end
            end
        end
    end
end


