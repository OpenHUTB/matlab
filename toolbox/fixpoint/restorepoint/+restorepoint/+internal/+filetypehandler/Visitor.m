classdef Visitor<handle




    methods
        function visit(obj,fileType)
            if isa(fileType,'restorepoint.internal.filetypehandler.ScriptFileType')
                obj.visitScriptFile(fileType);
            elseif isa(fileType,'restorepoint.internal.filetypehandler.ModelFileType')
                obj.visitModelFile(fileType);
            elseif isa(fileType,'restorepoint.internal.filetypehandler.MexFileType')
                obj.visitMexFile(fileType);
            elseif isa(fileType,'restorepoint.internal.filetypehandler.DDFileType')
                obj.visitDDFile(fileType);
            elseif isa(fileType,'restorepoint.internal.filetypehandler.OtherFileType')
                obj.visitOtherFile(fileType);
            end
        end
    end

    methods(Abstract,Access=protected)
        visitScriptFile(obj,fileType);
        visitModelFile(obj,fileType);
        visitDDFile(obj,fileType);
    end

    methods(Access=protected)

        function visitMexFile(~,~)
            return;
        end

        function visitOtherFile(~,~)
            return;
        end
    end
end


