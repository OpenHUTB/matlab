




function collectedObjects=collectObject(root,qualifiedName)
    metaClass=eval(strcat(char(qualifiedName),'.MetaClass'));
    m3iSeq=autosar.mm.Model.findObjectByMetaClass(root,metaClass,true);
    collectedObjects=eval(strcat(char(qualifiedName),'.empty(1,0)'));
    for ii=1:m3iSeq.size()
        collectedObjects(ii)=m3iSeq.at(ii);
    end
end


