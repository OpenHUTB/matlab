classdef BackgroundStyler<handle



    properties(Constant,Access=public)
        GreyEverythingStylerName='slxmlcomp.highlight.background'
        NoGreyStylerStylerName='slxmlcomp.highlight.nogrey'
        GreyEverythingClass='AllGrey'
        NoGreyClass='NotGrey'
        NoGreySegmentClass='NotGreySegment'
    end

    properties(Constant,Access=private)
        GreyPriority=2700
        NoGreyPriority=2900
    end

    properties(Access=private)
GreyEverythingStyler
NoGreyStyler
    end

    methods
        function obj=BackgroundStyler()
            obj.GreyEverythingStyler=obj.getOrCreateGreyEverythingStyler();
            obj.NoGreyStyler=obj.getOrCreateNoGreyStyler();
        end

        function applyStyle(obj,objToStyle)
            obj.GreyEverythingStyler.applyClass(...
            diagram.resolver.resolve(objToStyle),...
            obj.GreyEverythingClass...
            );
        end

        function hasBGStyle=hasStyle(obj,objToStyle)

            function hasStyle=objHasBGStyle(objToCheck)
                hasStyle=obj.GreyEverythingStyler.hasClass(objToCheck,obj.GreyEverythingClass)...
                &&~obj.NoGreyStyler.hasClass(objToCheck,obj.NoGreyClass)...
                &&~obj.NoGreyStyler.hasClass(objToCheck,obj.NoGreySegmentClass);
            end

            hasBGStyle=objHasBGStyle(diagram.resolver.resolve(objToStyle));
        end

        function applyNoGrey(obj,objToStyle)
            diagramObject=diagram.resolver.resolve(objToStyle);
            obj.NoGreyStyler.applyClass(diagramObject,obj.NoGreyClass);
            obj.NoGreyStyler.applyClass(diagramObject,obj.NoGreySegmentClass);
        end

        function removeNoGreyStyles(obj,parentToClear)
            do=diagram.resolver.resolve(parentToClear);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreySegmentClass,do);
        end

        function removeAllStyles(obj,parentToClear)
            do=diagram.resolver.resolve(parentToClear);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreySegmentClass,do);
            obj.GreyEverythingStyler.clearClasses(do);
            obj.GreyEverythingStyler.clearChildrenClasses(obj.GreyEverythingClass,do);
        end

        function styler=getOrCreateGreyEverythingStyler(obj)
            styler=diagram.style.getStyler(obj.GreyEverythingStylerName);

            if isempty(styler)





                diagram.style.createStyler(obj.GreyEverythingStylerName,obj.GreyPriority);
                styler=diagram.style.getStyler(obj.GreyEverythingStylerName);


                greyBDStyle=slxmlcomp.internal.highlight.style.Styles.greyBDStyle();
                slGreyEverythingStyle=slxmlcomp.internal.highlight.style.Styles.slGreyEverythingStyle();
                sfGreyEverythingStyle=slxmlcomp.internal.highlight.style.Styles.sfGreyEverythingStyle();

                greyAllSimulinkSelector=diagram.style.DescendantSelector({obj.GreyEverythingClass},{},{},{'simulink'});
                styler.addRule(slGreyEverythingStyle,greyAllSimulinkSelector);

                greyAllStateflowSelector=diagram.style.DescendantSelector({obj.GreyEverythingClass},{},{},{'stateflow'});
                styler.addRule(sfGreyEverythingStyle,greyAllStateflowSelector);

                classSelectorBDGrey=diagram.style.ClassSelector(obj.GreyEverythingClass);
                descendantSelectorBDGrey=diagram.style.DescendantSelector({obj.GreyEverythingClass},{},{},{});
                styler.addRule(greyBDStyle,classSelectorBDGrey);
                styler.addRule(greyBDStyle,descendantSelectorBDGrey);
            end
        end

        function styler=getOrCreateNoGreyStyler(obj)
            styler=diagram.style.getStyler(obj.NoGreyStylerStylerName);

            if isempty(styler)
                diagram.style.createStyler(obj.NoGreyStylerStylerName,obj.NoGreyPriority);
                styler=diagram.style.getStyler(obj.NoGreyStylerStylerName);


                noGreyStyle=slxmlcomp.internal.highlight.style.Styles.noGreyStyle();
                noGreySegmentStyle=slxmlcomp.internal.highlight.style.Styles.noGreySegmentStyle();

                styler.addRule(noGreyStyle,diagram.style.ClassSelector(obj.NoGreyClass));
                styler.addRule(noGreySegmentStyle,diagram.style.ClassSelector(obj.NoGreySegmentClass));
            end

        end

    end

end
