classdef(Abstract)AbstractFileManager<...
    evolutions.internal.datautils.SerializedAbstractInfoManager






    methods(Access=public)
        function obj=AbstractFileManager(fiType,project,rootFolder,artifactFolder)
            obj@evolutions.internal.datautils.SerializedAbstractInfoManager(...
            fiType,project,rootFolder,artifactFolder);
        end
    end
end
