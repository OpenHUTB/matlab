classdef UndoRedoCodeGenerator<matlab.internal.editor.CodeGenerator








    methods

        function this=UndoRedoCodeGenerator(fig,actionRegistrator)
            this=this@matlab.internal.editor.CodeGenerator(fig,actionRegistrator);
        end

        function deRegisterObject(~,~)

        end

        function deregisterAction(~,~,~)

        end
    end
end