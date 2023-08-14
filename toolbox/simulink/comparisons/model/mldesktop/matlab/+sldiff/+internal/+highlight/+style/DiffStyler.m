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
            diagramObject=diagram.resolver.resolve(objToStyle);
            obj.Styler.applyClass(diagramObject,StyleType.StyleClass);
        end

        function updateStyle(obj,objToStyle,StyleType)
            diagramObject=diagram.resolver.resolve(objToStyle);
            obj.Styler.clearClasses(diagramObject);
            obj.Styler.applyClass(diagramObject,StyleType.StyleClass);
        end

        function removeAllStyles(obj,parentToClear)
            import sldiff.internal.highlight.style.StyleType

            do=diagram.resolver.resolve(parentToClear);
            obj.Styler.clearClasses(do);
            for styleType=enumeration('sldiff.internal.highlight.style.StyleType')'
                obj.Styler.clearChildrenClasses(styleType.StyleClass,do);
            end
        end

    end

    methods
        function styler=get.Styler(obj)
            import sldiff.internal.highlight.style.Styles
            styler=diagram.style.getStyler(obj.Name);

            if isempty(styler)
                diagram.style.createStyler(obj.Name,obj.StylerPriority);
                styler=diagram.style.getStyler(obj.Name);

                for styleType=enumeration('sldiff.internal.highlight.style.StyleType')'
                    if styleType~=sldiff.internal.highlight.style.StyleType.Unmodified
                        style=Styles.get(styleType);
                        selector=diagram.style.ClassSelector(styleType.StyleClass);
                        styler.addRule(style,selector);
                    end
                end
            end
        end
    end
end
