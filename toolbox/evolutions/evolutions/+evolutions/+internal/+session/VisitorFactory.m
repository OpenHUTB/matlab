classdef VisitorFactory<handle





    properties(Access=private)
Write
Read
Delete
CopyFromBackup
DeleteBackup
Backup
    end

    methods
        function obj=VisitorFactory
            import evolutions.internal.classhandler.classVisitors.*
            obj.Write=Write;
            obj.Read=Read;
            obj.Delete=Delete;
            obj.CopyFromBackup=CopyFromBackup;
            obj.DeleteBackup=DeleteBackup;
            obj.Backup=Backup;
        end
    end

    methods
        function visitor=getVisitor(obj,type)

            visitor=obj.(type);
        end
    end
end
