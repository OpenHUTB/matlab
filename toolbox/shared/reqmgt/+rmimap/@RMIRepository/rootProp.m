function propValue=rootProp(this,rootName,varargin)

    myRoot=rmimap.RMIRepository.getRoot(this.graph,rootName);

    if isempty(myRoot)
        warning(message('Slvnv:rmigraph:UnmatchedModelName',rootName));
    else

        if length(varargin)==1

            if strcmp(varargin{1},'all')
                propValue=getAllValues(myRoot);
            else
                propValue=locGetPropValue(myRoot,varargin{1});

            end
        else
            t=M3I.Transaction(this.graph);
            propValue=locSetPropValue(myRoot,varargin{1},varargin{2});
            t.commit;
        end
    end
end


function value=locGetPropValue(theRoot,propName)
    value=[];
    for i=1:theRoot.data.names.size
        if strcmp(theRoot.data.names.at(i),propName)
            value=theRoot.data.values.at(i);
            return;
        end
    end
end


function origValue=locSetPropValue(theRoot,propName,newValue)
    origValue=[];
    if~ischar(newValue)
        newValue=num2str(newValue);
    end
    for i=1:theRoot.data.names.size
        if strcmp(theRoot.data.names.at(i),propName)
            origValue=theRoot.data.values.at(i);
            theRoot.data.values.erase(i);
            theRoot.data.values.insert(i,newValue);
            return;
        end
    end

    theRoot.data.names.append(propName);
    theRoot.data.values.append(newValue);
end


function props=getAllValues(theRoot)
    totalItems=theRoot.data.names.size;
    props=cell(totalItems,2);
    for i=1:totalItems
        props{i,1}=theRoot.data.names.at(i);
        props{i,2}=theRoot.data.values.at(i);
    end
end
