classdef BaseFileManager<evolutions.internal.file.AbstractFileManager




    properties(SetAccess=private,GetAccess=public)

        Constellation mf.zero.ModelConstellation
    end

    methods(Access=public)

        function obj=BaseFileManager(project,rootFolder,artifactFolder,constellation)
            obj=obj@evolutions.internal.file.AbstractFileManager(...
            'evolutions.model.BaseFileInfo',project,rootFolder,artifactFolder);
            obj.Constellation=constellation;
        end

        bfi=create(obj,project,idx)
        loadArtifacts(obj,bfi)
        bfi=getBaseFileInfoForFile(obj,fileName)
    end

end


