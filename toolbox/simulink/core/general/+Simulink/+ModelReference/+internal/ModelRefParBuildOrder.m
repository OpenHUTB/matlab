classdef ModelRefParBuildOrder<handle






    properties(Access=private)
ParentList
ChildrenList
ChildSimMode
GrandParentList
ProtectedChildrenList
ProtectedChildSimMode
ModelRefs
NodeList
ChildList
    end


    methods(Access=public)

        function this=ModelRefParBuildOrder()
            this.resetProperties();
        end




        function setElements(this,model,children,childSimMode,directParent,protectedChildren,protectedChildSimMode)
            [isModelInParentList,index]=ismember(model,this.ParentList);
            if isModelInParentList
                if~ismember(directParent,this.GrandParentList{index})
                    this.GrandParentList{index}=[this.GrandParentList{index},directParent];
                end
                return;
            end


            this.ParentList=[this.ParentList,model];
            this.ChildrenList=[this.ChildrenList,{children}];
            this.ChildSimMode=[this.ChildSimMode,{childSimMode}];
            this.GrandParentList=[this.GrandParentList,{directParent}];
            this.ProtectedChildrenList=[this.ProtectedChildrenList,{protectedChildren}];
            this.ProtectedChildSimMode=[this.ProtectedChildSimMode,{protectedChildSimMode}];
        end



        function result=getParallelBuildStruct(this,aStruct)
            this.NodeList=this.ParentList;
            this.ChildList=this.ChildrenList;
            this.ModelRefs=aStruct;


            this.filterProtectedModels();
            if isempty(this.ModelRefs)
                return;
            end


            this.filterNormalMode();


            result=this.processNodes();
        end


        function result=getParentAndChildrenLists(this)
            result.Parents=this.ParentList;
            result.Children=this.ChildrenList;
        end


        function result=getChildren(this,model)
            result.children={};
            result.childSimMode={};
            [isModelInParentList,index]=ismember(model,this.ParentList);
            if isModelInParentList
                result.children=this.ChildrenList{index};
                result.childSimMode=this.ChildSimMode{index};
            end
        end


        function result=getGrandParents(this,model)
            result.grandparents={};
            [isModelInParentList,index]=ismember(model,this.ParentList);
            if isModelInParentList
                result.grandparents=this.GrandParentList{index};
            end
        end


        function result=getProtectedChildren(this,model)
            result.children={};
            result.childSimMode={};
            [isModelInParentList,index]=ismember(model,this.ParentList);
            if isModelInParentList
                result.children=this.ProtectedChildrenList{index};
                result.childSimMode=this.ProtectedChildSimMode{index};
            end
        end
    end


    methods(Access=private)

        function resetProperties(this)
            this.ParentList={};
            this.ChildrenList={};
            this.ChildSimMode={};
            this.GrandParentList={};
            this.ProtectedChildrenList={};
            this.ProtectedChildSimMode={};
            this.ModelRefs=[];
            this.NodeList={};
            this.ChildList={};
        end


        function filterProtectedModels(this)
            this.ModelRefs=this.ModelRefs(~[this.ModelRefs.protected]);
        end


        function filterNormalMode(this)
            names={this.ModelRefs(:).modelName};
            [directChildren,index]=ismember(this.NodeList,names);
            if~all(directChildren)


                this.NodeList=this.NodeList(directChildren);
                this.ChildList=this.ChildList(directChildren);


                [~,index]=ismember(this.NodeList,names);
                sort(index);
            end
            this.ModelRefs=this.ModelRefs(index);
        end


        function result=processNodes(this)
            processedNodes={};
            result={};
            while(length(this.NodeList)>1)
                parNodes=[];


                for i=2:length(this.NodeList)
                    children=setdiff(this.ChildList{i},processedNodes);
                    if isempty(children)
                        parNodes=[parNodes,this.ModelRefs(i)];%#ok<AGROW>
                    end
                end

                result=[result,{parNodes}];%#ok<AGROW>
                parNames={parNodes(:).modelName};
                processedNodes=[processedNodes,parNames];%#ok<AGROW>
                [~,index]=setdiff(this.NodeList,parNames);
                index=sort(index);
                this.NodeList=this.NodeList(index);
                this.ChildList=this.ChildList(index);
                this.ModelRefs=this.ModelRefs(index);
            end
            result=[result,{this.ModelRefs(1)}];
        end
    end
end