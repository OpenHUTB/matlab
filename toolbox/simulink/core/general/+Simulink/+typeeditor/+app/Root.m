classdef Root<Simulink.typeeditor.app.Node




    events
ReferencedSLDDChanged
    end

    methods(Hidden,Access={?Simulink.typeeditor.app.Editor,...
        ?Simulink.typeeditor.app.EventData})
        function this=Root
            this.Children=Simulink.typeeditor.app.Source.empty;
        end
    end

    methods(Hidden)
        function children=getChildren(this,~)
            if~isempty(this.Children)

                children=this.Children;
                return;
            else


                children=Simulink.typeeditor.app.Source;
                this.Children=children;
            end
        end

        function root=getRoot(this)
            root=this;
        end

        function addChild(this,fileName)
            ed=this.getEditor;
            if ed.isVisible
                this.Children(end+1)=Simulink.typeeditor.app.Source(fileName);
                tc=ed.getTreeComp;
                tc.update(true);
                newNode=this.Children(end);
                if tc.isMinimized
                    ed.getListComp.setSource(newNode);
                end
                tc.view(newNode);
            end
        end

        function deleteChild(this,nodeName,inClose)

            nodeIdx=this.findIdx(nodeName);
            node=this.Children(nodeIdx);
            this.Children(nodeIdx)=[];

            if~inClose
                ed=this.getEditor;
                ed.getListComp.view([]);
                tc=ed.getTreeComp;
                tc.update(true);
                tc.view(this.Children(nodeIdx-1));
            end

            delete(node);
        end

        function res=find(this,name)
            resIdx=this.findIdx(name);
            if isempty(resIdx)
                res=Simulink.typeeditor.app.Source.empty;
            else
                res=this.Children(resIdx);
            end
        end

        function resIdx=findIdx(this,name)
            resIdx=find(strcmp(name,{this.Children.Name}));
        end


        function flag=isPresentByDD(this,filePath)


            if length(this.Children)==1
                flag=false;
            else
                [~,fileName,~]=fileparts(filePath);
                if~isempty(this.findIdx(fileName))
                    flag=true;
                else
                    flag=false;
                end
            end
        end

        function delete(this)
            if length(this.Children)>1

                slddNodes=this.Children(2:end);
                slddNodeConns=[slddNodes.NodeConnection];
                slddUnsavedIdxs=find([slddNodeConns.hasUnsavedChanges]);
                slddUnsaved=slddNodes(slddUnsavedIdxs);
                for i=1:length(slddUnsaved)
                    Simulink.typeeditor.actions.closeDictionary(slddUnsaved(i).Name,true);
                end


                delete(slddNodes(~slddUnsavedIdxs));
            end


            if~isempty(this.Children)
                delete(this.Children(1));
            end
        end
    end
end
