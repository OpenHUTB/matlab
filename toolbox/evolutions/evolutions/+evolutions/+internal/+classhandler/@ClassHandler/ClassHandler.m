classdef ClassHandler<handle




    methods(Static=true)
        DeleteObject(objClass);
        data=ReadObject(objClass);
        WriteObject(objClass);
        BackupObject(objClass);
        DeleteObjectBackup(objClass);
        CopyFromBackup(objClass);

        function visitObjects(objects,visitor)
            for idx=1:numel(objects)
                object=objects(idx);
                object.accept(visitor);
            end
        end
    end
end
