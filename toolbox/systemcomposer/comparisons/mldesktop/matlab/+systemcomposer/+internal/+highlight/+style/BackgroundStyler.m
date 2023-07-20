classdef BackgroundStyler<handle



    properties(Constant,Access=public)
        GreyEverythingStylerName='systemcomposer.comparisons.highlight.background'
        NoGreyStylerStylerName='systemcomposer.comparisons.highlight.nogrey'
        WhiteBGStylerStylerName='systemcomposer.comparisons.highlight.whitebackground'
        GreyEverythingClass='AllGrey'
        NoGreyClass='NotGrey'
        WhiteBGClass='WhiteBG'
    end

    properties(Constant,Access=private)
        GreyPriority=2700
        WhiteBGPriority=2800
        NoGreyPriority=2900
    end

    properties(Access=private)
GreyEverythingStyler
NoGreyStyler
WhiteBGStyler
    end

    methods
        function obj=BackgroundStyler()
            obj.GreyEverythingStyler=obj.getOrCreateGreyEverythingStyler();
            obj.NoGreyStyler=obj.getOrCreateNoGreyStyler();
            obj.WhiteBGStyler=obj.getOrCreateWhiteBGStyler();
        end

        function applyStyle(obj,objToStyle)
            obj.GreyEverythingStyler.applyClass(...
            diagram.resolver.resolve(objToStyle),...
            obj.GreyEverythingClass);
        end

        function hasBGStyle=hasStyle(obj,objToStyle)
            function hasStyle=objHasBGStyle(objToCheck)
                hasStyle=obj.GreyEverythingStyler.hasClass(objToCheck,obj.GreyEverythingClass)...
                &&~obj.NoGreyStyler.hasClass(objToCheck,obj.NoGreyClass)...
                &&~obj.WhiteBGStyler.hasClass(objToCheck,obj.WhiteBGClass);
            end
            hasBGStyle=objHasBGStyle(diagram.resolver.resolve(objToStyle));
        end

        function applyNoGrey(obj,objToStyle)
            diagramObject1=diagram.resolver.resolve(objToStyle);
            obj.NoGreyStyler.applyClass(diagramObject1,obj.NoGreyClass);
            if isequal(get_param(objToStyle,'Type'),'block')&&...
                isequal(get_param(objToStyle,'BlockType'),'SubSystem')
                diagramObject2=diagram.resolver.resolve(objToStyle,'diagram');
                obj.NoGreyStyler.applyClass(diagramObject2,obj.NoGreyClass);
            end
        end

        function removeNoGreyStyles(obj,parentToClear)
            do1=diagram.resolver.resolve(parentToClear);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do1);
            obj.WhiteBGStyler.clearChildrenClasses(obj.WhiteBGClass,do1);
            if isequal(get_param(parentToClear,'Type'),'block')&&...
                isequal(get_param(parentToClear,'BlockType'),'SubSystem')
                do2=diagram.resolver.resolve(parentToClear,'diagram');
                obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do2);
            end
        end

        function removeAllStyles(obj,parentToClear)
            do=diagram.resolver.resolve(parentToClear);
            obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do);
            obj.WhiteBGStyler.clearChildrenClasses(obj.WhiteBGClass,do);
            obj.GreyEverythingStyler.clearClasses(do);
            obj.GreyEverythingStyler.clearChildrenClasses(obj.GreyEverythingClass,do);
            if isequal(get_param(parentToClear,'Type'),'block')&&...
                isequal(get_param(parentToClear,'BlockType'),'SubSystem')
                do2=diagram.resolver.resolve(parentToClear,'diagram');
                obj.NoGreyStyler.clearChildrenClasses(obj.NoGreyClass,do2);
                obj.GreyEverythingStyler.clearClasses(do2);
                obj.GreyEverythingStyler.clearChildrenClasses(obj.GreyEverythingClass,do2);
            end
        end

        function styler=getOrCreateGreyEverythingStyler(obj)
            styler=diagram.style.getStyler(obj.GreyEverythingStylerName);

            if isempty(styler)
                diagram.style.createStyler(obj.GreyEverythingStylerName,obj.GreyPriority);
                styler=diagram.style.getStyler(obj.GreyEverythingStylerName);


                slGreyEverythingStyle=systemcomposer.internal.highlight.style.Styles.slGreyEverythingStyle();
                greyAllSimulinkSelector=diagram.style.DescendantSelector({obj.GreyEverythingClass},{},{},{'simulink'});
                styler.addRule(slGreyEverythingStyle,greyAllSimulinkSelector);

                greyBDStyle=systemcomposer.internal.highlight.style.Styles.greyBDStyle();
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


                noGreyStyle=systemcomposer.internal.highlight.style.Styles.noGreyStyle();

                styler.addRule(noGreyStyle,diagram.style.ClassSelector(obj.NoGreyClass));
            end
        end

        function styler=getOrCreateWhiteBGStyler(obj)
            styler=diagram.style.getStyler(obj.WhiteBGStylerStylerName);

            if isempty(styler)
                diagram.style.createStyler(obj.WhiteBGStylerStylerName,obj.WhiteBGPriority);
                styler=diagram.style.getStyler(obj.WhiteBGStylerStylerName);


                whiteBGStyle=systemcomposer.internal.highlight.style.Styles.whiteBGStyle();

                styler.addRule(whiteBGStyle,diagram.style.ClassSelector(obj.WhiteBGClass));
            end
        end

    end
    methods(Static)
        function tf=isMaskedBlock(handle)
            tf=strcmpi(get_param(handle,'Type'),'block')&&...
            strcmpi(get_param(handle,'Mask'),'on');
        end
    end
end
