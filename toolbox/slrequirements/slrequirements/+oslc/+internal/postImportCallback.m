function postImportCallback(topNode,srcInfo)




    isModule=strcmp(srcInfo.type,'module');
    topChildren=topNode.children;
    for i=1:numel(topChildren)
        assignTypeAndIndex(topChildren(i),isModule);
    end
end

function assignTypeAndIndex(item,isModule)
    externalType=item.externalTypeName;
    switch externalType
    case 'Heading'
        item.typeName='Container';
        children=item.children;
        for i=1:numel(children)
            assignTypeAndIndex(children(i),isModule);
        end
    case 'Information'
        item.typeName='Informational';
        item.enableHIdx(false);
    case 'Diagrams and sketches'
        item.typeName='Informational';
        item.enableHIdx(false);
    otherwise



        if isModule&&~isempty(externalType)
            item.enableHIdx(false);
        end


    end
end
