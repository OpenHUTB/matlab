classdef Backup<evolutions.internal.classhandler.classVisitors.Visitor




    methods(Access=?evolutions.internal.classhandler.classVisitors.Visitor)
        visitBaseFileInfo(obj,baseFileInfo)

        visitEvolutionInfo(obj,evolutionInfo)

        visitEdge(obj,edge)

        visitEvolutionTreeInfo(obj,evolutionTreeInfo)

    end

    methods(Static,Access=private)
        backupSerializableInfo(info)
    end

end


