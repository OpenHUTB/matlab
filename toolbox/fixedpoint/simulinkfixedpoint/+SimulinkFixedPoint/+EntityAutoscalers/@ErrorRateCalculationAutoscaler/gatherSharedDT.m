function sharedLists=gatherSharedDT(h,blockObject)





    sharedLists={};


    sharedLists=[sharedLists,{hShareSrcAtSamePort(h,blockObject)}];


    sharedLists=[sharedLists,{hShareDTSpecifiedPorts(h,blockObject,[1,2],[])}];


    nSharedLists=numel(sharedLists);
    invalidIndices=false(1,nSharedLists);
    for ii=1:nSharedLists
        if isempty(sharedLists{ii})
            invalidIndices(ii)=true;
        end
    end
    sharedLists(invalidIndices)=[];
end
