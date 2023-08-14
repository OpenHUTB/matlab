function showConfigSetInDataDictionary(dataDictionaryName,configSetName)
















    dd=Simulink.data.dictionary.open(dataDictionaryName);
    me=daexplr;
    node=me.getTreeSelection;


    fullname=['Data Dictionary/Configurations ''',which(dataDictionaryName),''''];
    if~strcmp(node.getFullName,fullname)

        show(dd);




        imme=DAStudio.imExplorer(daexplr);
        current=imme.getCurrentTreeNode;
        siblings=getHierarchicalChildren(current);
        node=siblings(arrayfun(@(x)strcmp(x.getFullName,fullname),siblings));
        me.view(node);
    end

    if nargin>1




        imme=DAStudio.imExplorer(daexplr);
        list=imme.getVisibleListNodes;
        idx=cellfun(@(x)strcmp(x.getFullName,configSetName),list);
        if~any(idx)

            throw(MSLException([],message('configset:util:ConfigSetNotFoundInDataDictionary',...
            configSetName,dataDictionaryName)));
        else
            item=[list{idx}];
            me.view(item);
        end
    else

        me.view([]);
    end
