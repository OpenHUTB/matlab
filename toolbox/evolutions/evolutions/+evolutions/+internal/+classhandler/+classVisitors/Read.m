classdef Read<evolutions.internal.classhandler.classVisitors.Visitor




    properties
ObjectData
    end

    methods(Access=?evolutions.internal.classhandler.classVisitors.Visitor)
        function visitBaseFileInfo(this,object)
            data=this.getCommonData(object);


            [data.Path,name,ext]=fileparts(object.File);
            data.Name=sprintf("%s%s",name,ext);
            this.ObjectData=data;
        end

        function visitEdgeInfo(this,object)
            data=this.getCommonData(object);
            nodes=cell.empty;
            for idx=1:numel(object.Nodes)
                nodes{end+1}=object.Nodes(idx).Id;%#ok<AGROW> 
            end

            data.EdgeNodes=nodes;
            data.Stereotypes='';
            this.ObjectData=data;
        end

        function visitEvolutionInfo(this,object)
            data=this.getCommonData(object);
            data.Parent='';
            if~isempty(object.Parent)
                data.Parent=object.Parent.Id;
            end
            children=cell.empty;
            for idx=1:numel(object.Children)
                children{end+1}=object.Children(idx).Id;%#ok<AGROW> 
            end

            data.Children=children;
            data.IsWorking=object.IsWorking;
            data.Stereotypes='';
            files=containers.Map;
            for idx=1:numel(object.Infos.toArray)
                bfi=object.Infos(idx);
                files(bfi.File)=bfi.Id;
            end
            data.Files=files;
            this.ObjectData=data;
        end

        function visitEvolutionTreeInfo(this,object)
            data=this.getCommonData(object);
            data.Stereotypes='';
            data.RootEvolution=object.RootEvolution.Id;
            data.WorkingEvolution=object.EvolutionManager.WorkingEvolution.Id;
            this.ObjectData=data;
        end
    end

    methods(Static=true,Access=private)
        function commonData=getCommonData(object)
            commonData=struct();
            commonData.Id=object.Id;
            commonData.Name=object.getName;
            commonData.Created=object.Created;
            commonData.Updated=object.Updated;
            commonData.Author=object.Author;
            commonData.Description=object.Description;
        end
    end
end
