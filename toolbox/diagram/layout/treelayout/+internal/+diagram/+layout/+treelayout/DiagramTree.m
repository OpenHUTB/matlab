classdef DiagramTree



    properties
        mRootIndex;
        mIndices;
        mDiagram;
        mParents;
        mChildren;
        mWidths;
        mHeights;
    end

    methods
        function obj=DiagramTree(diagram,model)


            obj.mRootIndex=numel(diagram.entities)+1;
            obj.mIndices=containers.Map;
            obj.mDiagram=diagram;

            obj.mParents=containers.Map;
            obj.mChildren=containers.Map;
            obj.mWidths=containers.Map;
            obj.mHeights=containers.Map;

            typeNames=strings(1,numel(diagram.entities));
            for i=(1:numel(diagram.entities))
                e=diagram.entities(i);
                uuid=string(e.uuid);
                obj.mIndices(uuid)=i;
                obj.mParents(uuid)=obj.getRoot();
                obj.mChildren(uuid)=[];
                elem=model.findElement(string(e.uuid));
                obj.mWidths(uuid)=elem.size.width;
                obj.mHeights(uuid)=elem.size.height;
                if~isempty(elem.attributes)
                    typeNameAttr=elem.attributes.attributes.getByKey('typeName');
                    if~isempty(typeNameAttr)
                        typeNames(i)=string(typeNameAttr.value);
                    end
                end




            end
            itemOrders=[string({diagram.entities.uuid})',typeNames',string({diagram.entities.title})'];

            rootUuid=obj.getRoot();
            obj.mIndices(rootUuid)=obj.mRootIndex;
            obj.mParents(rootUuid)=[];
            obj.mChildren(rootUuid)=[];
            obj.mWidths(rootUuid)=10;
            obj.mHeights(rootUuid)=10;


            useDfsForLayout=true;
            if useDfsForLayout
                testParents=containers.Map;
                testChildren=containers.Map;
                testParents("0")=[];
                parentMap=internal.diagram.layout.treelayout.diagramDFS(diagram);
                testChildren("0")=[];
                for e=diagram.entities'
                    testChildren(string(e.uuid))=[];
                end
                for childCell=parentMap.keys
                    child=string(childCell{:});
                    parent=string(parentMap(child));


                    testParents(child)=parent;
                    testChildren(parent)=[testChildren(parent),child];
                end

                obj.mParents=testParents;
                obj.mChildren=testChildren;
                for e=diagram.entities'
                    uuid=string(e.uuid);
                    obj.sortChildren(uuid,itemOrders);
                end
                root=obj.getRoot();
                obj.sortChildren(root,itemOrders);

            else

                for c=diagram.connections'
                    if isa(c.source,'diagram.interface.Port')
                        src=string(c.source.parent.uuid);
                    else
                        src=string(c.source.uuid);
                    end

                    if isa(c.destination,'diagram.interface.Port')
                        dst=string(c.destination.parent.uuid);
                    else
                        dst=string(c.destination.uuid);
                    end




                    if strcmp(obj.mParents(src),rootUuid)
                        obj.mChildren(dst)=[obj.mChildren(dst),src];

                        obj.mParents(src)=dst;



                    end
                end

                root=obj.getRoot();
                for e=diagram.entities'
                    uuid=string(e.uuid);
                    if obj.mParents(uuid)==root
                        obj.mChildren(root)=[obj.mChildren(root),uuid];
                    end
                    obj.sortChildren(uuid,itemOrders);
                end
                obj.sortChildren(root,itemOrders);

            end
        end



        function sortChildren(obj,uuid,itemOrders)
            children=obj.mChildren(uuid)';
            toSort=strings(numel(children),5);
            for i=1:numel(children)
                toSort(i,[1,3,5])=itemOrders(obj.mIndices(children(i)),:);
            end
            toSort(:,4)=upper(toSort(:,5));
            toSort(:,2)=upper(toSort(:,3));
            sorted=sortrows(toSort,[2,3,4,5]);
            obj.mChildren(uuid)=sorted(:,1)';
        end

        function node=getRoot(~)
            node="0";
        end

        function index=getIndex(obj,node)
            index=obj.mIndices(node);
        end

        function node=getNodeByIndex(obj,index)
            if(index==obj.mRootIndex)
                node=obj.getRoot();
            else
                node=string(obj.mDiagram.entities(index).uuid);
            end
        end

        function val=isLeaf(obj,node)
            val=isempty(obj.mChildren(node));
        end

        function val=isChildOfParent(obj,node,parentNode)
            val=obj.getParent(node)==parentNode;
        end

        function children=getChildren(obj,node)
            children=obj.mChildren(node);
        end

        function children=getChildrenReverse(obj,node)
            children=fliplr(obj.getChildren(node));
        end

        function child=getFirstChild(obj,node)
            children=obj.mChildren(node);
            child=children(1);
        end

        function child=getLastChild(obj,node)
            children=obj.mChildren(node);
            child=children(end);
        end

        function parent=getParent(obj,node)
            parent=obj.mParents(node);
        end

        function height=getNodeHeight(obj,node)
            height=obj.mHeights(node);
        end

        function width=getNodeWidth(obj,node)
            width=obj.mWidths(node);
        end
    end
end

