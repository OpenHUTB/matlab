
function calleeMapKey=setupCurrentTreeAttributes(this,callerFcnTypeInfo,callerNode,callerIteration,callerMapKey)






    calleeMapKey=callerFcnTypeInfo.generateCalleeKey(callerNode);
    if~isempty(callerMapKey)
        calleeMapKey=[callerMapKey,' ',calleeMapKey];
    end
    calleeTreeAttributes=this.treeAttributesMap(calleeMapKey);
    for ii=callerIteration
        assert(isKey(calleeTreeAttributes,ii),'callee tree attributes at the specified loop iteration is not found');
        calleeTreeAttributes=calleeTreeAttributes(ii);
    end
    assert(isa(calleeTreeAttributes,'internal.mtree.MTreeAttributes'),'unexpected tree attributes object found');
    this.treeAttributes=calleeTreeAttributes;
end


