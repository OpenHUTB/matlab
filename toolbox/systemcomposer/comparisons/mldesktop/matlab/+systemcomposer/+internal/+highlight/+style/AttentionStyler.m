classdef AttentionStyler<handle

    properties(Constant,Access=public)
        Name='systemcomposer.comparisons.highlight.attention'
        StyleClass='highlighted'
        StylerPriority=3000
    end


    properties(Dependent,Access=private)
Styler
    end


    methods
        function applyHighlight(obj,objToStyle)
            obj.Styler.applyClass(...
            diagram.resolver.resolve(objToStyle),...
            obj.StyleClass...
            );
        end


        function removeCurrentHighlight(obj,objToStyle)
            obj.Styler.removeClass(...
            diagram.resolver.resolve(objToStyle),...
            obj.StyleClass...
            );
        end


        function removeAllStyles(obj,parentToClear)
            do=diagram.resolver.resolve(parentToClear);
            obj.Styler.clearClasses(do);
            obj.Styler.clearChildrenClasses(obj.StyleClass,do);
        end

    end


    methods
        function styler=get.Styler(obj)
            styler=diagram.style.getStyler(obj.Name);

            if isempty(styler)
                diagram.style.createStyler(obj.Name,obj.StylerPriority);
                styler=diagram.style.getStyler(obj.Name);

                highlightedStyle=systemcomposer.internal.highlight.style.Styles.highlighted();
                styler.addRule(highlightedStyle,diagram.style.ClassSelector(obj.StyleClass));
            end
        end
    end

end
