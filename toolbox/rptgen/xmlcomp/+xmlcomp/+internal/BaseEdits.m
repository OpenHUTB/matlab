classdef BaseEdits<handle&xmlcomp.internal.NodeAccessor







    properties(GetAccess=public,SetAccess=private)


        Filters=[];
        LeftFileName='';
        LeftRoot=[];
        RightFileName='';
        RightRoot=[];
        TimeSaved='';
    end

    properties(GetAccess=public,Constant=true)
        Version='2.0';
    end

    methods(Access=protected)

        function obj=BaseEdits(comparisonFacade,nodeFactory)


            obj.TimeSaved=datestr(now,0);


            obj.createNodes(...
            comparisonFacade.getLeftNodeList(),...
            comparisonFacade.getRightNodeList(),...
nodeFactory...
            );

            obj.LeftFileName=char(comparisonFacade.getLeftFile().getAbsolutePath());
            obj.RightFileName=char(comparisonFacade.getRightFile().getAbsolutePath());


            obj.createFilters(comparisonFacade.getFilters());
        end
    end

    methods(Access=private)
        function obj=createFilters(obj,filters)

            obj.Filters=[];
            iterator=filters.getFilters().iterator();
            while iterator.hasNext()
                filter=iterator.next();
                if filters.isVisible(filter)
                    Filter.Name=char(filter.getName());
                    Filter.Value=filters.isEnabled(filter);
                    obj.Filters=[obj.Filters,Filter];
                end
            end
        end

        function obj=createNodes(obj,leftList,rightList,nodeFactory)


            jNodeList=java.util.ArrayList(leftList);
            jNodeList.addAll(rightList);

            emptyNode=xmlcomp.Node();
            mNodeList=repmat(emptyNode,jNodeList.size(),1);


            mNodeList=obj.createMNodes(jNodeList,mNodeList,nodeFactory);


            obj.LeftRoot=mNodeList(jNodeList.indexOf(leftList.get(0))+1);
            obj.RightRoot=mNodeList(jNodeList.indexOf(rightList.get(0))+1);


            obj.attachReferences(jNodeList,mNodeList);
        end

        function mList=createMNodes(~,jList,mList,nodeFactory)



            iterator=jList.iterator();
            while iterator.hasNext()
                jNode=iterator.next();
                index=jList.indexOf(jNode)+1;
                baseNode=nodeFactory(jNode);
                mList(index)=xmlcomp.Node(baseNode);
            end
        end

        function obj=attachReferences(obj,jList,mList)



            iterator=jList.iterator();
            while iterator.hasNext()
                jNode=iterator.next();
                index=jList.indexOf(jNode)+1;


                partner=jNode.getPartner();
                parent=jNode.getParent();


                if~isempty(partner)
                    assert(jList.contains(partner));
                    partnerIndex=jList.indexOf(partner)+1;
                    mList(index).Partner=mList(partnerIndex);
                end


                if~isempty(parent)&&jList.contains(parent)
                    parentIndex=jList.indexOf(parent)+1;
                    child=mList(index);
                    parent=mList(parentIndex);
                    child.Parent=parent;
                end
            end
        end

    end

    methods(Static,Access=public)


        function checkArgument(argument,expectedType)

            if isa(argument,expectedType)
                return
            end

            xmlcomp.internal.error('engine:IncorrectArgument',['argument: ',class(argument)],expectedType);
        end
    end

end
