classdef TreeNode<handle&matlab.mixin.Heterogeneous









    properties
Id
Parent
Children
        TriggerUpdate=1;
    end

    properties(Hidden=true)
UniqId
    end

    methods
        function self=TreeNode

            self.UniqId=randn(1)*(1e10);
        end

        function addParent(self,Parent)





            if~isempty(self.Parent)&&self.Parent.UniqId==Parent.UniqId
                return;
            end
            removeParent(self);
            self.Parent=Parent;
            addChild(self.Parent,self);
            parentChanged(self);



        end

        function par=getFinalParent(self)
            par=self;
            while~isempty(par.Parent)
                par=par.Parent;
            end
        end

        function updated(self)
            if~self.TriggerUpdate
                return;
            end



            if~isempty(self.Parent)&&isvalid(self.Parent)

                childUpdated(self.Parent,self);
            end

            for i=1:numel(self.Children)
                if isvalid(self.Children(i))

                    parentUpdated(self.Children(i),self);
                end
            end
        end

        function n=getNodeDepth(self)
            obj=self;
            n=1;
            while~isempty(obj.Parent)
                n=n+1;
                obj=obj.Parent;
            end
        end

        function removeParent(self)



            if isempty(self.Parent)

                return;
            end
            if~isvalid(self.Parent)


                self.Parent=[];
                parentChanged(self);
                return;
            end

            parentObj=self.Parent;

            self.Parent=[];

            if~isempty(parentObj.Children)

                removeChild(parentObj,self);
            end

            parentObj.childrenChanged();

            parentChanged(self);
        end

        function childrenChanged(self)

        end

        function parentChanged(self)

        end

        function parentUpdated(self,childObj)


        end

        function childUpdated(self,childObj)


        end

        function addChild(self,newChild,varargin)




            indx=numel(self.Children)+1;
            if~isempty(varargin)

                indx=varargin{1};
            end
            if~isempty(self.Children)&&any([self.Children.UniqId]==newChild.UniqId)


                return;
            end

            removeParent(newChild)

            if indx<=numel(self.Children)&&indx>1
                self.Children=[self.Children(1:indx-1),newChild,self.Children(indx:end)];
            elseif indx==1
                self.Children=[newChild,self.Children];
            else
                self.Children=[self.Children,newChild];
            end

            addParent(newChild,self);

            childrenChanged(self);

            updated(self);
        end

        function addTreeListeners(self)

            deleteListeners(self);
        end

        function removeChild(self,oldChild)



            if isempty(self.Children)
                return;
            end


            idx=zeros(1,numel(self.Children));
            for j=1:numel(self.Children)
                if~isvalid(self.Children(j))
                    idx(j)=1;
                end
            end
            self.Children(logical(idx))=[];


            for i=1:numel(oldChild)

                if~isvalid(oldChild(i))
                    oldChild(i)=[];
                    continue;
                end



                indx=[self.Children.UniqId]==oldChild(i).UniqId;
                if~any(indx)
                    continue;
                end


                oldChild(i).parentUpdated();

                self.Children(indx)=[];

                if any(indx)&&~isempty(oldChild(i).Parent)

                    removeParent(oldChild(i));
                end
            end

            childrenChanged(self);

            updated(self);
        end

        function deleteListeners(self)



        end

        function info=getInfo(self)


            try
                info.Id=self.Id;

                if~isempty(self.Parent)
                    info.ParentId=self.Parent.Id;
                    info.ParentChildrenId=[self.Parent.Children.Id];
                    info.ParentParentId=[];
                    if~isempty(self.Parent.Parent)
                        info.ParentParentId=self.Parent.Parent.Id;
                    end
                else
                    info.ParentId=[];
                    info.ParentParentId=[];
                    info.ParentChildrenId=[];
                end
                if~isempty(self.Children)
                    info.ChildrenId=[self.Children.Id];
                    info.ChildrenChildrenId=cell(1,numel(self.Children));
                    for i=1:numel(self.Children)
                        if~isempty(self.Children(i).Children)
                            info.ChildrenChildrenId{i}=[self.Children(i).Children.Id];
                        else
                            info.ChildrenChildrenId{i}=[];
                        end
                    end

                else
                    info.ChildrenChildrenId=cell(1,numel(self.Children));
                    info.ChildrenId=[];
                end
            catch me
                info=[];
            end

        end
        function delete(self)

            deleteNode(self);
        end
        function deleteNode(self)
            self.notify('BeingDeleted');
            deleteListeners(self);
            removeParent(self);
            removeChild(self,self.Children);
        end


    end
    events
BeingDeleted
Updated
    end

end
