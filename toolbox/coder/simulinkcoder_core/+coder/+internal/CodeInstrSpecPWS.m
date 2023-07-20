classdef(Hidden=true)CodeInstrSpecPWS<coder.internal.CodeInstrSpec




    methods(Access=public)

        function folders=getInstrObjFolders(~,modules,~)
            folder=rtw.connectivity.Utils.getSilHostObjSubDir;
            folders=cell(size(modules));
            [folders{1:end}]=deal(folder);
        end


        function[folder,relativePathToParent]=getSharedUtilObjFolder(~)
            [folder,relativePathToParent]=rtw.connectivity.Utils.getSilHostObjSubDir;
        end

    end

end
