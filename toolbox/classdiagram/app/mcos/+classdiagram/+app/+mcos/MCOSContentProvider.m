classdef MCOSContentProvider<mdom.BaseDataProvider
    properties(SetObservable=true)
        RootCount=0;
        ElementMap;
        ChildrenMap;


        ParentIDMap;
        Factory;
        RootItemIDs;
    end

    properties(Constant)
        Root='_INVISIBLE_ROOT_';
    end

    methods(Static)
        function ret=hasChildren(package)
            metadata=meta.package.fromName(package.getName());
            ret=~isempty(metadata)&&...
            (~isempty(metadata.PackageList)||~isempty(metadata.ClassList));
        end
    end

    methods
        function obj=MCOSContentProvider(factory,rootItems)
            obj.Factory=factory;
            obj.ElementMap=containers.Map;
            obj.ChildrenMap=containers.Map;
            obj.ParentIDMap=containers.Map;
            obj.RootItemIDs=[obj.ToContentID(rootItems)];


            obj.ChildrenMap(obj.Root)=[];


            obj.RootCount=length(obj.ChildrenMap(obj.Root));
        end

        function requestData(obj,ev)



            rowList=ev.RowInfoRequests;
            rowInfo=mdom.RowInfo(rowList);
            pID='';
            rowMetaList={};
            for r=1:length(rowList)
                rIndex=rowList(r);
                if rIndex.RowIndex==-1
                    continue;
                end
                rowPID=rIndex.ParentID;

                if~strcmp(pID,rowPID)
                    rowMetaList=obj.ChildrenMap(rowPID);
                    pID=rowPID;
                end

                if isempty(rowMetaList)
                    return;
                end

                if rIndex.RowIndex+1<=rowMetaList.length
                    pkgOrClass=obj.ElementMap(rowMetaList(rIndex.RowIndex+1));

                    rowInfo.setRowID(rIndex,obj.ToContentID(pkgOrClass.getObjectID()));

                    dm=obj.getDataModel;
                    if dm.isRowExpanded(dm.getIDForIndex(rIndex))
                        rowInfo.setRowExpanded(rIndex,true);
                        rowInfo.setRowHasChild(rIndex,mdom.HasChild.YES);
                    elseif isa(pkgOrClass,'classdiagram.app.core.domain.Package')


                        if strcmpi(pID,obj.Root)||obj.hasChildren(pkgOrClass)
                            rowInfo.setRowHasChild(rIndex,mdom.HasChild.MAYBE);
                        end
                    end
                end
            end
            ev.addRowInfo(rowInfo);


            colList=ev.ColumnInfoRequests;
            colInfo=mdom.ColumnInfo(colList);
            for c=1:length(colList)
                meta=mdom.MetaData;
                meta.setProp('label','Classes');
                meta.setProp('renderer','VCRenderer');
                widthMeta=mdom.MetaData;
                widthMeta.setProp('unit','%');
                widthMeta.setProp('value',100);
                meta.setProp('width',widthMeta);
                colInfo.fillMetaData(colList(c),meta);
            end

            ev.addColumnInfo(colInfo);


            ranges=ev.RangeRequests;
            data=mdom.Data;
            for i=1:length(ranges)
                rangeData=mdom.RangeData(ranges(i));
                rowPID=ranges(i).ParentID;
                if strcmp(rowPID,'')
                    continue;
                end
                if~strcmp(pID,rowPID)
                    if~obj.ChildrenMap.isKey(rowPID)
                        return;
                    end
                    rowMetaList=obj.ChildrenMap(rowPID);
                    pID=rowPID;
                end

                if isempty(rowMetaList)
                    return;
                end

                for r=ranges(i).RowStart:ranges(i).RowEnd
                    a=-1;
                    if ranges(i).RowStart==a
                        continue;
                    end

                    if r+1<=rowMetaList.length
                        for c=ranges(i).ColumnStart:ranges(i).ColumnEnd
                            element=obj.ElementMap(rowMetaList(r+1));
                            data.clear();
                            s=split(element.getName(),'.');
                            data.setProp('label',s{length(s)});
                            if isa(element,'classdiagram.app.core.domain.Package')
                                data.setProp('iconUri','editor-ui/images/package_16.png');
                            elseif isa(element,'classdiagram.app.core.domain.Class')
                                data.setProp('iconUri','editor-ui/images/class_16.png');
                            else
                                data.setProp('iconUri','editor-ui/images/enumeration_16.png');
                            end
                            data.setProp('id',obj.ToContentID(element.getObjectID()));

                            rangeData.fillData(r,c,data);
                        end
                    end
                end
                ev.addRangeData(rangeData);
            end

            ev.send();
        end

        function onExpand(obj,id)
            if~isempty(id)
                dm=obj.getDataModel;

                dm.rowChanged(id,length(obj.ChildrenMap(id)),{});


                obj.expandSubNodesIfNeeded(id)
            end
        end

        function onCollapse(obj,id)
            if~isempty(id)
                dm=obj.getDataModel;
                dm.rowChanged(id,0,{});
            end
        end

        function updateClass(obj,class)
            if isempty(class.getDiagramElementUUID)
                classID=obj.getContentID(class);
                obj.handleDelete(classID);
                return;
            end
            dm=obj.getDataModel;
            classID=obj.getContentID(class);

            if~obj.ElementMap.isKey(classID)
                packageId=obj.populateParent(class);
                obj.addNewClass(classID,class,packageId);
            else
                index=dm.getIndexForID(classID);
                if(index.RowIndex~=-1)
                    dm.rangeDataChanged(mdom.Range(index.ParentID,0,index.RowIndex,0,0));
                end
            end
        end

        function updatePackage(obj,pkg)
            pkgID=obj.ToContentID(pkg.getObjectID);
            if(obj.ElementMap.isKey(pkgID)&&obj.ChildrenMap.isKey(pkgID))

                dm=mdom.DataModel.findDataModel(obj.DataModelID);
                dm.refreshView;
            end
        end

        function refreshHierarchy(obj)
            obj.refreshSubHierarchy(obj.Root);
        end
    end

    methods(Hidden)
        function debugReset(obj)
            obj.ParentIDMap=containers.Map;
            obj.ChildrenMap=containers.Map;
            obj.ElementMap=containers.Map;
            obj.ChildrenMap(obj.Root)=[];
        end
    end


    methods(Hidden=true)
        function topnodes=getRootNodes(obj)
            topnodes=obj.ChildrenMap(obj.Root);
        end

        function nodeInfo=getNodeInfo(obj,nodeID)
            import classdiagram.app.core.domain.*;

            nodeInfo=struct();
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
            node=obj.ElementMap(nodeID);

            nodeInfo.ID=nodeID;

            nodeInfo.Expanded=dm.isRowExpanded(nodeID);
            nodeInfo.Expandable=false;
            if isa(node,'Package')
                nodeInfo.Expandable=true;
            end

            if isa(node,'Package')
                nodeInfo.icon='editor-ui/images/package_16.png';
            elseif isa(node,'Class')
                nodeInfo.icon='editor-ui/images/class_16.png';
            elseif isa(node,'Enum')
                nodeInfo.icon='editor-ui/images/enumeration_16.png';
            end
        end
    end

    methods(Access=private)
        function addToChildrenMap(obj,cdObjID,packageId)
            if~obj.ChildrenMap.isKey(packageId)||isempty(obj.ChildrenMap(packageId))
                obj.ChildrenMap(packageId)=cdObjID;
                return;
            end
            packageChildren=obj.ChildrenMap(packageId);
            if~ismember(cdObjID,packageChildren)
                obj.ChildrenMap(packageId)=[packageChildren,cdObjID];

            end
        end

        function addNewClass(obj,cdObjID,cdObj,packageId)
            dm=obj.getDataModel;
            obj.ElementMap(cdObjID)=cdObj;
            obj.addToChildrenMap(cdObjID,packageId);
            obj.ParentIDMap(cdObjID)=packageId;
            dm.rowChanged(packageId,length(obj.ChildrenMap(packageId)),{});
            obj.updateRowChildrenIds(packageId);
        end

        function addPackageToHeirarchy(obj,packageId,package,parentPackage)
            obj.ElementMap(packageId)=package;
            obj.addToChildrenMap(packageId,parentPackage);
            obj.ParentIDMap(packageId)=parentPackage;

            dm=obj.getDataModel;
            dm.rowChanged(parentPackage,length(obj.ChildrenMap(parentPackage)),{});
            obj.updateRowChildrenIds(parentPackage);

            dm.updateRowID(mdom.RowIndex(parentPackage,length(obj.ChildrenMap(parentPackage))-1),packageId);
        end

        function parentId=populateParent(obj,cdObject)


            parentId=obj.Root;


            if isa(cdObject,'classdiagram.app.core.domain.PackageElement')
                package=cdObject.getOwningPackage;
            else
                metadata=meta.package.fromName(cdObject.getName);
                if isempty(metadata)
                    return;
                end
                if isempty(metadata.ContainingPackage)

                    package=[];
                else
                    package=obj.Factory.getPackage(metadata.ContainingPackage.Name);
                    if isempty(package)

                        return;
                    end
                end
            end

            if isempty(package)
                parentId=obj.Root;
                return;
            end

            packageId=obj.getContentID(package);


            if obj.ElementMap.isKey(packageId)
                parentId=packageId;
                return;
            end

            if ismember(packageId,obj.RootItemIDs)
                parentId=obj.Root;
            else

                parentId=obj.populateParent(package);
            end


            obj.addPackageToHeirarchy(packageId,package,parentId);
            parentId=packageId;
        end

        function handleDelete(obj,cdObjID)
            dm=obj.getDataModel;
            rowIndex=dm.getIndexForID(cdObjID);
            if rowIndex.RowIndex==-1
                parentId=obj.ParentIDMap(cdObjID);
            else
                parentId=rowIndex.ParentID;
            end
            remove(obj.ElementMap,cdObjID);
            children=obj.ChildrenMap(parentId);
            children(children==cdObjID)=[];
            obj.ChildrenMap(parentId)=children;

            if isempty(children)
                dm.rowChanged(parentId,0,{});
                if~strcmp(parentId,obj.Root)
                    obj.handleDelete(parentId);
                end
            else
                dm.rowChanged(parentId,length(children),{});
                obj.updateRowChildrenIds(parentId);
                for child=children
                    if obj.ChildrenMap.isKey(child)
                        dm.rowChanged(child,length(obj.ChildrenMap(child)),{});
                        obj.updateRowChildrenIds(child);
                    end

                end
            end
        end

        function updateRowChildrenIds(obj,parentPackage)



            dm=obj.getDataModel;
            children=obj.ChildrenMap(parentPackage);
            for i=1:length(children)
                child=children(i);
                dm.updateRowID(mdom.RowIndex(parentPackage,i-1),child);
            end
        end

        function id=ToContentID(~,id)
            id="viewcontent--"+id;
        end

        function id=getContentID(obj,cdObject)
            id=obj.ToContentID(cdObject.getObjectID);
        end

        function dm=getDataModel(obj)
            dm=mdom.DataModel.findDataModel(obj.DataModelID);
        end

        function refreshSubHierarchy(obj,pID)
            if obj.ChildrenMap.isKey(pID)
                nodes=obj.ChildrenMap(pID);
                sortedNodes=obj.sortNames(nodes);
                obj.ChildrenMap(pID)=sortedNodes;

                dm=obj.getDataModel;
                dm.rowChanged(pID,length(sortedNodes),{});
                obj.updateRowChildrenIds(pID);
                arrayfun(@(id)obj.refreshSubHierarchy(id),sortedNodes);
            end
        end

        function sortedNames=sortNames(~,names)
            sortedNames=[];
            if isempty(names)
                return;
            end
            idx=startsWith(names,'viewcontent--Package|');
            packages=names(idx);

            domainObjects=names(~idx);
            sortedNames=[classdiagram.app.core.utils.sortNames(packages)...
            ,classdiagram.app.core.utils.sortNames(domainObjects)];
        end

        function expandSubNodesIfNeeded(obj,id)
            metaList=obj.ChildrenMap(id);
            dm=obj.getDataModel;
            for k=1:length(metaList)
                element=obj.ElementMap(metaList(k));
                if isa(element,'classdiagram.app.core.domain.Package')
                    subId=obj.ToContentID(element.getObjectID);
                    if dm.isRowExpanded(subId)

                        dm.updateRowID(mdom.RowIndex(id,k-1),subId);

                        dm.rowChanged(subId,length(obj.ChildrenMap(subId)),{});

                        obj.expandSubNodesIfNeeded(subId);
                    end
                end
            end
        end
    end
end
