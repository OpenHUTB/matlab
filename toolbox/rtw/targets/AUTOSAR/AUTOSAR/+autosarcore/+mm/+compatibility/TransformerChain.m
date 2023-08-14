



classdef TransformerChain<handle
    properties
        table=cell(0,3);
    end

    methods
        function addNewVersion(self,version,exportFunction,importFunction)
            self.table(end+1,:)={version,exportFunction,importFunction};
        end

        function addExportersToFactory(self,factory,targetRelease)





            if isempty(self.table)
                return
            end
            self.sort('descend');
            exportTable=self.table(:,[1,2]);
            autosarcore.mm.compatibility.TransformerChain.addTransformers(factory,targetRelease,exportTable);
        end

        function addImportersToFactory(self,factory,targetRelease)




            if isempty(self.table)
                return
            end
            self.sort('ascend');
            importTable=self.table(:,[1,3]);
            autosarcore.mm.compatibility.TransformerChain.addTransformers(factory,targetRelease,importTable);
        end


        function sort(self,sortOrder)



            versions=cellfun(@(x)x,self.table(:,1));
            [~,sortIndex]=sort(versions,sortOrder);
            self.table=self.table(sortIndex,:);
        end
    end

    methods(Static,Access=private)
        function addTransformers(factory,targetRelease,table)




            for tt=table'
                if tt{1}<targetRelease
                    continue
                end

                if~isempty(tt{2})
                    tr=autosarcore.mm.compatibility.Transformer();
                    tt{2}(tr);
                    factory.appendTransformer(tr);
                end
            end
        end
    end
end
