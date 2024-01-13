classdef FileHelper

    methods(Static=true)

        function checkWriteRights(fileName)
            [status,values]=fileattrib(fileName);
            if~status||~values.UserWrite
                error(message('polyspace:pscore:noWriteRights',fileName))
            end
        end


        function path=normalizeFolderPath(path)
            if~isfolder(path)&&~isfile(path)
                path=pssharedprivate('getOrCreateDir',path);
                clrObj=onCleanup(@()rmdir(path,'s'));
            end
            path=polyspace.internal.getAbsolutePath(path);
        end
    end
end
