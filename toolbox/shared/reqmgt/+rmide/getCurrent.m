function dictPath=getCurrent(name)


    dictPath='';

    if~rmiut.isMeOpen()
        return;
    end

    try
        me=daexplr;
        imme=DAStudio.imExplorer;
        imme.setHandle(me);
        if nargin==0

            node=imme.getCurrentTreeNode;
            if isa(node,'Simulink.DataDictionaryScopeNode')
                node=node.getParent();
            end
            if isa(node,'Simulink.DataDictionaryRootNode')
                dictPath=getFullPath(node);
            end
        else

            [~,name]=fileparts(name);
            allTreeNodes=imme.getVisibleTreeNodes;
            for i=1:length(allTreeNodes)
                if strcmp(allTreeNodes{i}.getDisplayLabel,name)
                    if isa(allTreeNodes{i},'Simulink.DataDictionaryRootNode')
                        dictPath=getFullPath(allTreeNodes{i});
                        return;
                    end
                end
            end
        end
    catch ex
        if nargin>1
            disp(['Failed to figure out full path for ',name]);
        else
            disp('Failed to figure out current dictionary in Model Explorer');
        end
        disp(ex.message);
    end
end

function fullPath=getFullPath(node)
    fullNameString=node.getFullName();
    quoteIdx=strfind(fullNameString,'''');
    fullPath=fullNameString(quoteIdx(1)+1:quoteIdx(end)-1);
end
