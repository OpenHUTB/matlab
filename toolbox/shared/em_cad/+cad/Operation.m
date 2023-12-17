classdef(Abstract)Operation<cad.TreeNode

    properties
Name
Type
Index

        CategoryType='Operation';
    end


    methods
        function self=Operation(name,type,Id)

            self.Id=Id;
            self.Name=name;
            self.Type=type;
        end


        function setIndex(self,val)
            self.Index=val;
        end


        function boolshape=performOperation(self,shape)

            boolshape=shape;
        end


        function childUpdated(self,~)
            updated(self);
        end


        function info=getInfo(self)
            info=self.getInfo@cad.TreeNode();

            info.Type=self.Type;
            if~isempty(self.Parent)
                info.ParentType=self.Parent.Type;
                info.ParentParentType={};
                if~isempty(self.Parent.Parent)
                    info.ParentParentType=self.Parent.Parent.Type;
                end
            else
                info.ParentType={};
                info.ParentParentType={};
            end
            if~isempty(self.Children)
                info.ChildrenType={self.Children.Type};
            else
                info.ChildrenType={};
            end
            info.ChildrenChildrenIType=cell(1,numel(self.Children));
            for i=1:numel(self.Children)
                if~isempty(self.Children(i).Children)
                    info.ChildrenChildrenType{i}={self.Children(i).Children.Type};
                else
                    info.ChildrenChildrenType{i}={};
                end
            end
            info.Index=self.Index;

        end
    end
end

