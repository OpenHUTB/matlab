classdef DiffStyler<handle




    properties(Constant,Access=public)
        Name='comparisons.highlight.diff'
        StylerPriority=2950
    end

    properties(Dependent,Access=private)
Styler
    end

    methods

        function applyStyle(obj,objToStyle,StyleType)
            diagramObject1=diagram.resolver.resolve(objToStyle);
            obj.Styler.applyClass(diagramObject1,StyleType.StyleClass);
            if systemcomposer.internal.highlight.style.BackgroundStyler.isMaskedBlock(objToStyle)
                whiteBGStyler=diagram.style.getStyler(systemcomposer.internal.highlight.style.BackgroundStyler.WhiteBGStylerStylerName);
                whiteBGStyler.applyClass(diagramObject1,systemcomposer.internal.highlight.style.BackgroundStyler.WhiteBGClass);
            end
            if isequal(get_param(objToStyle,'Type'),'block')&&...
                isequal(get_param(objToStyle,'BlockType'),'SubSystem')
                diagramObject2=diagram.resolver.resolve(objToStyle,'diagram');
                obj.Styler.applyClass(diagramObject2,StyleType.StyleClass);
            end
        end

        function updateStyle(obj,objToStyle,StyleType)
            diagramObject1=diagram.resolver.resolve(objToStyle);
            obj.Styler.clearClasses(diagramObject1);
            obj.Styler.applyClass(diagramObject1,StyleType.StyleClass);
            if isequal(get_param(objToStyle,'Type'),'block')&&...
                isequal(get_param(objToStyle,'BlockType'),'SubSystem')
                diagramObject2=diagram.resolver.resolve(objToStyle,'diagram');
                obj.Styler.clearClasses(diagramObject2);
                obj.Styler.applyClass(diagramObject2,StyleType.StyleClass);
            end
        end

        function removeAllStyles(obj,parentToClear)
            import sldiff.internal.highlight.style.*

            do1=diagram.resolver.resolve(parentToClear);
            obj.Styler.clearClasses(do1);
            for styleType=enumeration('sldiff.internal.highlight.style.StyleType')'
                obj.Styler.clearChildrenClasses(styleType.StyleClass,do1);
            end
            if isequal(get_param(parentToClear,'Type'),'block')&&...
                isequal(get_param(parentToClear,'BlockType'),'SubSystem')
                do2=diagram.resolver.resolve(parentToClear,'diagram');
                obj.Styler.clearClasses(do2);
                for styleType=enumeration('sldiff.internal.highlight.style.StyleType')'
                    obj.Styler.clearChildrenClasses(styleType.StyleClass,do2);
                end
            end
        end
    end

    methods
        function styler=get.Styler(obj)
            import systemcomposer.internal.highlight.style.Styles
            styler=diagram.style.getStyler(obj.Name);

            if isempty(styler)
                diagram.style.createStyler(obj.Name,obj.StylerPriority);
                styler=diagram.style.getStyler(obj.Name);

                for styleType=enumeration('sldiff.internal.highlight.style.StyleType')'
                    style=Styles.get(styleType);
                    selector=diagram.style.ClassSelector(styleType.StyleClass);
                    styler.addRule(style,selector);
                end
            end
        end
    end
end
