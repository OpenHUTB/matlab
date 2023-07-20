classdef FileTypeHandler<handle




    properties(GetAccess=public,SetAccess=private)
FileType
NeedsRestoreVisitor
CloseElementVisitor
FindDirtyFilesVisitor
SaveDirtyFilesVisitor
    end

    methods
        function set.NeedsRestoreVisitor(obj,visitor)
            validateattributes(visitor,...
            {'restorepoint.internal.filetypehandler.Visitor'},{'nonempty'});
            obj.NeedsRestoreVisitor=visitor;
        end
        function set.CloseElementVisitor(obj,visitor)
            validateattributes(visitor,...
            {'restorepoint.internal.filetypehandler.Visitor'},{'nonempty'});
            obj.CloseElementVisitor=visitor;
        end
        function set.FindDirtyFilesVisitor(obj,visitor)
            validateattributes(visitor,...
            {'restorepoint.internal.filetypehandler.Visitor'},{'nonempty'});
            obj.FindDirtyFilesVisitor=visitor;
        end
        function set.SaveDirtyFilesVisitor(obj,visitor)
            validateattributes(visitor,...
            {'restorepoint.internal.filetypehandler.Visitor'},{'nonempty'});
            obj.SaveDirtyFilesVisitor=visitor;
        end
    end

    methods
        function closeElements(obj,fileData)
            obj.FileType=...
            restorepoint.internal.filetypehandler.FileTypeFactory.getFileType(fileData);
            obj.CloseElementVisitor=restorepoint.internal.filetypehandler.CloseElementVisitor;
            obj.FileType.accept(obj.CloseElementVisitor);
        end
        function fileIsDirty=findDirtyFiles(obj,fileData)
            obj.FileType=...
            restorepoint.internal.filetypehandler.FileTypeFactory.getFileType(fileData);
            obj.FindDirtyFilesVisitor=restorepoint.internal.filetypehandler.FindDirtyFilesVisitor;
            obj.FileType.accept(obj.FindDirtyFilesVisitor);
            fileIsDirty=obj.FindDirtyFilesVisitor.IsDirty;
        end
        function saveDirtyFile(obj,fileData)
            obj.FileType=...
            restorepoint.internal.filetypehandler.FileTypeFactory.getFileType(fileData);
            obj.SaveDirtyFilesVisitor=restorepoint.internal.filetypehandler.SaveDirtyFilesVisitor;
            obj.FileType.accept(obj.SaveDirtyFilesVisitor);
        end
    end

end




