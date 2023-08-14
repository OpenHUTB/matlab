classdef FunctionSelectedStyler<handle







    properties(Constant)
        StylerName='DefaultComponentSelectionStyler';
        StyleClass='DefaultComponentSelector';
    end

    methods(Static)
        function removeStyle(blockHandle)
            import swarch.internal.spreadsheet.FunctionSelectedStyler;

            styler=FunctionSelectedStyler.getStyler();
            if blockHandle~=-1&&~isempty(styler)
                styler.removeClass(blockHandle,FunctionSelectedStyler.StyleClass);
            end
        end

        function applyStyle(blockHandle)

            import swarch.internal.spreadsheet.FunctionSelectedStyler;

            if FunctionSelectedStyler.hasStyle(blockHandle)
                return;
            end



            FunctionSelectedStyler.removeStyle(blockHandle);

            if~ishandle(blockHandle)
                return;
            end

            diagObj=diagram.resolver.resolve(blockHandle);
            if diagObj.isNull()
                return;
            end

            FunctionSelectedStyler.getStyler().applyClass(diagObj,...
            FunctionSelectedStyler.StyleClass);
        end

        function styled=hasStyle(blockHandle)
            import swarch.internal.spreadsheet.FunctionSelectedStyler;

            styled=false;

            styler=FunctionSelectedStyler.getStyler();
            if isempty(styler)
                return;
            end

            styled=styler.hasClass(blockHandle,FunctionSelectedStyler.StyleClass);
        end
    end

    methods(Static,Access=private)
        function styler=getStyler()

            styler=diagram.style.getStyler(...
            swarch.internal.spreadsheet.FunctionSelectedStyler.StylerName);
        end
    end
end
