




classdef PackageTreeNode<handle
    properties
ID
DisplayIcon
DisplayLabel
Children

    end

    methods

        function obj=PackageTreeNode(name,id,icon)
            assert(nargin>=1&&(ischar(name)||isStringScalar(name)));
            obj.DisplayLabel=name;
            if isempty(icon)
                obj.DisplayIcon=autosar.ui.metamodel.PackageString.IconMap('Package');
            else
                obj.DisplayIcon=icon;
            end
            if nargin==3
                obj.ID=id;
            else
                obj.ID=0;
            end
        end


        function id=getID(obj)
            id=obj.ID;
        end


        function txt=getDisplayLabel(obj)
            txt=obj.DisplayLabel;
        end

        function fname=getDisplayIcon(obj)
            fname=obj.DisplayIcon;
        end


        function haschld=hasChildren(obj)
            haschld=~isempty(obj.Children);
        end


        function chld=getHierarchicalChildren(obj)
            chld=obj.Children;
        end

    end
end
