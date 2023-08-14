classdef BusTreeNodeCompatibleInterface<Simulink.iospecification.TreeCompatibleInterface




    properties
        CAN_BE_AoB=false
    end


    methods


        function treeObjectEl=getTreeObjectElement(obj,treeObject,elementNames,idx)

            treeObjectEl=Simulink.iospecification.RootInportBusElement.getTreeNode(treeObject,elementNames{idx});

        end


        function busElPlugin=getTreePlugin(obj,treeObjectElement)
            IS_BUS=~Simulink.iospecification.RootInportBusElement.isTreeNodeALeaf(treeObjectElement);

            if IS_BUS
                busElPlugin=Simulink.iospecification.BusElTreeNodeBranch(treeObjectElement,obj.Handle);
                busElPlugin.Handle=obj.Handle;
                busElPlugin.ALLOW_PARTIAL=obj.ALLOW_PARTIAL;
            else
                busElPlugin=Simulink.iospecification.BusElTreeNodeLeaf(treeObjectElement,obj.Handle);
            end

        end


        function elNames=getBusElementNames(obj,treeObject)

            elNames=Simulink.iospecification.RootInportBusElement.getLeafNamesFromTree(treeObject,true);

        end

    end


end
