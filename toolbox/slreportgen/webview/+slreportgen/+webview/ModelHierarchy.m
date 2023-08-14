classdef ModelHierarchy<handle





























    properties(Access=private)
        m_map;
        m_idmap;
    end

    methods(Static)
        function objectPath=getObjectPath(obj)
            if(ischar(obj)&&~slreportgen.utils.isSID(obj))
                objectPath=obj;
            else
                hs=slreportgen.utils.HierarchyService;
                dhid=hs.getDiagramHID(obj);
                objectPath=hs.getPath(dhid);
            end

            objectPath=regexprep(objectPath,'\s',' ');
        end
    end

    methods
        function h=ModelHierarchy(objs)
            h.m_map=containers.Map();
            h.m_idmap=containers.Map("KeyType","uint64","ValueType","any");
            if((nargin>0)&&~isempty(objs))
                addItems(h,objs);
            end
        end

        function item=getItem(h,obj)
            map=h.m_map;
            objectPath=char(h.getObjectPath(obj));
            item=[];
            if isKey(map,objectPath)
                item=h.m_map(objectPath);
            end
        end

        function item=getItemByID(h,id)
            item=[];
            if isKey(h.m_idmap,id)
                item=h.m_idmap(id);
            end
        end

        function tf=hasItem(h,obj)
            objectPath=char(h.getObjectPath(obj));
            tf=isKey(h.m_map,objectPath);
        end

        function n=getNumberOfItems(h)
            n=double(h.m_map.Count);
        end

        function rootItems=getRootItems(h)
            rootItems=[];
            items=getAllItems(h);
            nItems=numel(items);
            for i=1:nItems
                item=items(i);
                if isRoot(item)
                    rootItems=cat(2,rootItems,item);
                end
            end
        end

        function items=getAllItems(h)
            tmp=values(h.m_map);
            items=cat(2,tmp{:});
        end

        function paths=getAllItemPaths(h)
            paths=string(keys(h.m_map));
        end

        function checkedItems=getCheckedItems(h)
            checkedItems=getAllItems(h);
            n=numel(checkedItems);
            idx=true(1,n);
            for i=1:n
                idx(i)=isChecked(checkedItems(i));
            end
            checkedItems=checkedItems(idx);
        end

        function uncheckedItems=getUncheckedItems(h)
            uncheckedItems=getAllItems(h);
            n=numel(uncheckedItems);
            idx=true(1,n);
            for i=1:n
                idx(i)=isUnchecked(uncheckedItems(i));
            end
            uncheckedItems=uncheckedItems(idx);
        end

        function partiallyCheckedItems=getPartiallyCheckedItems(h)
            partiallyCheckedItems=getAllItems(h);
            n=numel(partiallyCheckedItems);
            idx=true(1,n);
            for i=1:n
                idx(i)=isPartiallyChecked(partiallyCheckedItems(i));
            end
            partiallyCheckedItems=partiallyCheckedItems(idx);
        end

        function items=addItems(h,objs)
            hs=slreportgen.utils.HierarchyService;
            map=h.m_map;
            idmap=h.m_idmap;
            items=[];

            if ischar(objs)
                objs={objs};
            end

            nObjs=numel(objs);
            for i=1:nObjs
                if iscell(objs)
                    obj=objs{i};
                else
                    obj=objs(i);
                end

                try
                    objPath=h.getObjectPath(obj);
                    pathSplits=cellstr(slreportgen.utils.pathSplit(objPath));
                    nPathSplits=numel(pathSplits);

                    parentItem=[];
                    pathParts='';
                    for j=1:nPathSplits
                        pathParts=[pathParts,pathSplits{j}];%#ok
                        if~isKey(map,pathParts)
                            dhid=hs.getDiagramHID(pathParts);
                            ehid=hs.getParent(dhid);

                            itemID=map.Count+1;
                            newItem=slreportgen.webview.ModelHierarchyItem(dhid,ehid,itemID);
                            setCheckState(newItem,newItem.UNCHECKED);
                            if~isempty(parentItem)
                                setParent(newItem,parentItem);
                                setChildren(parentItem,[getChildren(parentItem),newItem]);
                            end
                            setModelHierarchy(newItem,h);
                            map(pathParts)=newItem;
                            idmap(newItem.ID)=newItem;

                            parentItem=newItem;
                        else
                            parentItem=map(pathParts);
                        end
                        pathParts=[pathParts,'/'];%#ok
                    end


                    setCheckState(parentItem,parentItem.CHECKED);

                    items=[items,parentItem];%#ok
                catch ME
                    warning(ME.identifier,'%s',ME.message);
                end
            end

            updateCheckStates(h);
        end

        function varargout=addItemsAndTheirAncestors(h,objs)
            if ischar(objs)
                objs={objs};
            end

            addedItems=addItems(h,objs);
            nAddedItems=numel(addedItems);
            for i=1:nAddedItems
                addedItem=addedItems(i);

                pItem=getParent(addedItem);
                while~isempty(pItem)
                    setCheckState(pItem,pItem.CHECKED);
                    pItem=getParent(pItem);
                end
            end
            updateCheckStates(h);

            if(nargout>0)
                items=[];
                nObjs=numel(objs);
                for i=1:nObjs
                    if iscell(objs)
                        obj=objs{i};
                    else
                        obj=objs(i);
                    end
                    item=getItem(h,obj);
                    items=[items,getAncestors(item),item];%#ok
                end
                varargout{1}=items;
            end
        end

        function varargout=addItemsAndTheirDescendants(h,objs,filter)
            if(nargin<3)
                filter=slreportgen.webview.ModelHierarchyFilter();
            end

            if ischar(objs)
                objs={objs};
            end

            hs=slreportgen.utils.HierarchyService;
            map=h.m_map;
            idmap=h.m_idmap;

            loadReferencedModel=filter.IncludeReferencedModels;
            loadLibraries=filter.IncludeUserLibraryLinks||filter.IncludeSimulinkLibraryLinks;

            items=addItems(h,objs);
            stack=fliplr(items);
            while~isempty(stack)
                item=stack(end);
                stack(end)=[];

                dhid=getDiagramHierarchyId(item);
                cehids=hs.getChildren(dhid,...
                'loadLibraries',loadLibraries,...
                'LoadReferencedModel',loadReferencedModel);


                nCehids=numel(cehids);
                for k=1:nCehids
                    try
                        cehid=cehids(k);
                        cehid=filter.filter(cehid);
                        if~isempty(cehid)
                            cdhid=hs.getChildren(cehid,...
                            'loadLibraries',loadLibraries,...
                            'LoadReferencedModel',loadReferencedModel);
                            cdhid=cdhid(1);

                            itemID=map.Count+1;
                            newItem=slreportgen.webview.ModelHierarchyItem(cdhid,cehid,itemID);
                            setParent(newItem,item);
                            newItemPath=char(getPath(newItem));
                            if~isKey(map,newItemPath)
                                setChildren(item,[getChildren(item),newItem]);
                                setModelHierarchy(newItem,h);

                                map(newItemPath)=newItem;
                                idmap(newItem.ID)=newItem;
                            else
                                newItem=getItem(h,newItemPath);
                            end
                            setCheckState(newItem,newItem.CHECKED);
                            stack(end+1)=newItem;%#ok
                        end
                    catch ME
                        warning(ME.identifier,'%s',ME.message);
                    end
                end
            end

            updateCheckStates(h);

            if(nargout>0)
                items=[];
                nObjs=numel(objs);
                for i=1:nObjs
                    if iscell(objs)
                        obj=objs{i};
                    else
                        obj=objs(i);
                    end
                    item=getItem(h,obj);
                    items=[items,item,getDescendants(item,filter)];%#ok
                end
                varargout{1}=items;
            end
        end

        function varargout=addItemsFromRootAndTheirDescendants(h,objs,varargin)
            if ischar(objs)
                objs={objs};
            end

            nObjs=numel(objs);
            rootObjs=cell(1,nObjs);

            if iscell(objs)
                for k=1:nObjs
                    rootObjs{k}=slreportgen.utils.getModelHandle(objs{k});
                end
            else
                for k=1:nObjs
                    rootObjs{k}=slreportgen.utils.getModelHandle(objs(k));
                end
            end

            if(nargout>0)
                varargout{1}=addItemsAndTheirDescendants(h,rootObjs,varargin{:});
            else
                addItemsAndTheirDescendants(h,rootObjs,varargin{:});
            end
        end

        function removeItems(h,objs)
            map=h.m_map;
            idmap=h.m_idmap;

            if ischar(objs)
                objs={objs};
            end

            nObjs=numel(objs);
            for i=1:nObjs
                if iscell(objs)
                    obj=objs{i};
                else
                    obj=objs(i);
                end

                item=getItem(h,obj);
                descendants=getDescendants(item);
                nDescendants=numel(descendants);
                for j=1:nDescendants
                    descendant=descendants(j);
                    if isKey(idmap,descendant.ID)
                        descendantPath=char(getPath(descendant));
                        remove(map,descendantPath);
                        remove(idmap,descendant.ID);
                        delete(descendant);
                    end
                end

                remove(map,char(getPath(item)));
                remove(idmap,item.ID);
                delete(item);
            end

            updateCheckStates(h);
        end
    end

    methods(Access=private)
        function updateCheckStates(h)

            items=getAllItems(h);
            nItems=numel(items);


            for i=1:nItems
                item=items(i);
                if isPartiallyChecked(item)
                    setCheckState(item,item.UNCHECKED);
                end
            end

            for i=nItems:-1:1
                item=items(i);
                if(isChecked(item)||isPartiallyChecked(item))

                    pItem=getParent(item);
                    if(~isempty(pItem)&&isUnchecked(pItem))
                        setCheckState(pItem,pItem.PARTIAL);
                    end
                end
            end
        end
    end
end

