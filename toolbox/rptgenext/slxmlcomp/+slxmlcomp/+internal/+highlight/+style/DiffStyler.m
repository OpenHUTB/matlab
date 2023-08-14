classdef DiffStyler<handle




    properties(Constant,Access=public)
        Name='slxmlcomp.highlight.diff'
        StylerPriority=2950
    end

    properties(Dependent,Access=private)
Styler
    end

    properties(Access=private)
Id
OnCleanups
    end

    methods
        function obj=DiffStyler()




            obj.Id=matlab.lang.internal.uuid;
            obj.OnCleanups={};
            obj.addStylesToStyler();

            idList=slxmlcomp.internal.highlight.style.DiffStylerIdList.getInstance();
            idList.add(obj.Id);
            id=obj.Id;
            obj.OnCleanups={obj.OnCleanups,onCleanup(@()idList.remove(id))};
        end

        function applyStyle(obj,objToStyle,styleType)
            diagramObject=diagram.resolver.resolve(objToStyle);
            obj.Styler.applyClass(diagramObject,obj.getStyleClass(styleType));
        end

        function updateStyle(obj,objToStyle,styleType)
            diagramObject=diagram.resolver.resolve(objToStyle);
            obj.Styler.clearClasses(diagramObject);
            obj.Styler.applyClass(diagramObject,obj.getStyleClass(styleType));
        end

        function removeAllStyles(obj,parentToClear)
            import slxmlcomp.internal.highlight.style.StyleType

            do=diagram.resolver.resolve(parentToClear);
            obj.Styler.clearClasses(do);
            for styleType=enumeration('slxmlcomp.internal.highlight.style.StyleType')'
                obj.Styler.clearChildrenClasses(obj.getStyleClass(styleType),do);
            end
        end

    end

    methods
        function styler=get.Styler(obj)
            styler=diagram.style.getStyler(obj.Name);

            if isempty(styler)
                diagram.style.createStyler(obj.Name,obj.StylerPriority);
                styler=diagram.style.getStyler(obj.Name);
            end
        end

        function addStylesToStyler(obj)
            import slxmlcomp.internal.highlight.style.Styles

            styler=obj.Styler;
            for styleType=enumeration('slxmlcomp.internal.highlight.style.StyleType')'
                style=Styles.get(styleType);
                selector=diagram.style.ClassSelector(obj.getStyleClass(styleType));
                rule=styler.addRule(style,selector);
                obj.OnCleanups{end+1}=onCleanup(@()rule.remove());
            end
        end

    end

    methods(Access=private)

        function styleClass=getStyleClass(obj,styleType)
            styleClass=strcat(styleType.StyleClass,obj.Id);
        end

    end
end
