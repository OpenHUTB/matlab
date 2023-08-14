classdef FigureEventDisabler<handle







    properties(Access=private)
        InitialValue=false;
    end

    methods(Hidden)
        function obj=FigureEventDisabler()
            import matlab.internal.editor.FigureEventDisabler
            obj.InitialValue=FigureEventDisabler.disable();
        end

        function delete(obj)
            import matlab.internal.editor.FigureEventDisabler
            FigureEventDisabler.restore(obj.InitialValue);
        end
    end

    methods(Static)
        function oldValue=disable()
            oldValue=builtin('_StructuredFiguresSetEnablement',false);
        end

        function oldValue=enable()
            oldValue=builtin('_StructuredFiguresSetEnablement',true);
        end

        function restore(value)
            builtin('_StructuredFiguresSetEnablement',value);
        end
    end
end

