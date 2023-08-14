classdef Delete<evolutions.internal.classhandler.classVisitors.Visitor




    methods(Access=?evolutions.internal.classhandler.classVisitors.Visitor)
        function visitBaseFileInfo(this,baseFile)
            this.removeAndDeleteFile(baseFile.Project,baseFile.XmlFile);
            dirToDelete=fileparts(baseFile.XmlFile);
            this.removeAndDeleteDir(baseFile.Project,dirToDelete);
            this.destroyMfObject(baseFile);
        end

        function visitEdge(this,edge)
            this.removeAndDeleteFile(edge.Project,edge.XmlFile);
            dirToDelete=fileparts(edge.XmlFile);
            this.removeAndDeleteDir(edge.Project,dirToDelete);
            this.destroyMfObject(edge);
        end

        function visitEvolutionInfo(this,evolutionInfo)
            this.removeAndDeleteFile(evolutionInfo.Project,evolutionInfo.XmlFile);
            dirToDelete=fileparts(evolutionInfo.XmlFile);
            this.removeAndDeleteDir(evolutionInfo.Project,dirToDelete);
            this.destroyMfObject(evolutionInfo);
        end

        function visitEvolutionTreeInfo(this,evolutionTreeInfo)
            this.removeAndDeleteFile(evolutionTreeInfo.Project,evolutionTreeInfo.XmlFile);
            dirToDelete=fileparts(evolutionTreeInfo.XmlFile);
            this.removeAndDeleteDir(evolutionTreeInfo.Project,dirToDelete);
            this.destroyMfObject(evolutionTreeInfo);
        end

    end

    methods(Static=true,Access=protected)
        function destroyMfObject(info)

            evolutions.internal.utils.destroyMfObject(info);
        end

        function removeAndDeleteFile(project,filePath)
            evolutions.internal.utils.removeAndDeleteFile(project,filePath);
        end

        function removeAndDeleteDir(project,directory)
            evolutions.internal.utils.removeAndDeleteDir(project,directory);
        end
    end
end


