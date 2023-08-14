classdef Visitor<handle




    methods
        function visit(obj,fileType)
            if isa(fileType,'evolutions.internal.filetypehandler.MFileType')
                obj.visitMFile(fileType);
            elseif isa(fileType,'evolutions.internal.filetypehandler.MlxFileType')
                obj.visitMlxFile(fileType);
            elseif isa(fileType,'evolutions.internal.filetypehandler.ModelFileType')
                obj.visitModelFile(fileType);
            elseif isa(fileType,'evolutions.internal.filetypehandler.MexFileType')
                obj.visitMexFile(fileType);
            elseif isa(fileType,'evolutions.internal.filetypehandler.DDFileType')
                obj.visitDDFile(fileType);
            elseif isa(fileType,'evolutions.internal.filetypehandler.MatFileType')
                obj.visitMatFile(fileType);
            elseif isa(fileType,'evolutions.internal.filetypehandler.XMLFileType')
                obj.visitXMLFile(fileType);
            elseif isa(fileType,'evolutions.internal.filetypehandler.OtherFileType')
                obj.visitOtherFile(fileType);
            end
        end
    end

    methods(Access=protected)

        function visitMFile(~,~)
            return;
        end
        function visitMlxFile(~,~)
            return;
        end
        function visitModelFile(~,~)
            return;
        end
        function visitDDFile(~,~)
            return;
        end

        function visitMexFile(~,~)
            return;
        end

        function visitOtherFile(~,~)
            return;
        end

        function visitMatFile(~,~)
            return;
        end

        function visitXMLFile(~,~)
            return;
        end
    end
end


