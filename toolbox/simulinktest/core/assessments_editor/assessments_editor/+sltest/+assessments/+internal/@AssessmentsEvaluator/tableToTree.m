function tree=tableToTree(table,childKey,valueKey)


    tree=struct.empty();
    nodeMap=containers.Map('KeyType','double','ValueType','any');


    for k=length(table):-1:1
        row=table{k};

        if nodeMap.isKey(row.id)
            children=nodeMap(row.id);
            row.children=orderfields(children,flipud(fieldnames(children)));
            nodeMap.remove(row.id);
        end

        if row.parent==-1
            if isempty(tree)
                tree=row;
            else
                tree(end+1)=row;%#ok<AGROW>
            end
        else
            if~nodeMap.isKey(row.parent)
                children=struct();
            else
                children=nodeMap(row.parent);
            end
            key=row.(childKey);
            key=sanitizeKey(key);
            assert(~isfield(key,children),'no keys should not be repeated (key: %s)',key);
            if nargin>=3
                children.(key)=row.(valueKey);
            else
                children.(key)=row;
            end
            nodeMap(row.parent)=children;
        end
    end

    tree=fliplr(tree);
end

function key=sanitizeKey(key)
    key=replace(key,[" ","/"],'');
    delimeters=["_","-"];


    if startsWith(key,delimeters)||endsWith(key,delimeters)
        key=regexprep(key,'^[-_]+|[-_]+$|/','');
    end

    if contains(key,delimeters)
        key=regexprep(key,'[-_]+([a-z])','${upper($1)}');
    end
end
