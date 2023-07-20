




classdef MarkupStyleSheet<handle
    properties(Constant)
        MARKUP_STYLER_NAME='MathWorks.MarkupVisibilityStyler';
        MARKUP_STYLER_TAG='MathWorks.GLUE2Styler:Markup';
        MARKUP_HIDDEN_STYLER_TAG='HiddenMarkUp';
        MARKUP_VISIBLE_STYLER_TAG='VisibleMarkUp';
    end



    methods(Static)

        function visible=isMarkupVisible(bdHandle)
            showMarkup=get_param(bdHandle,'ShowMarkup');
            visible=strcmp(showMarkup,'on');
        end

        function applyStyler(bdHandle)


            markupVisible=SLStudio.MarkupStyleSheet.isMarkupVisible(bdHandle);

            styler=diagram.style.getStyler(SLStudio.MarkupStyleSheet.MARKUP_STYLER_NAME);
            if(isempty(styler))
                diagram.style.createStyler(SLStudio.MarkupStyleSheet.MARKUP_STYLER_NAME);
                styler=diagram.style.getStyler(SLStudio.MarkupStyleSheet.MARKUP_STYLER_NAME);

                hiddenStyle=diagram.style.Style;
                hiddenStyle.set('Opacity',0.0);


                markupStyle=diagram.style.Style;
                markupStyle.set('FillColor',[0.9,0.9,1.0,0.6]);


                visibleDescSelector=diagram.style.DescendantSelector({SLStudio.MarkupStyleSheet.MARKUP_VISIBLE_STYLER_TAG},{},{SLStudio.MarkupStyleSheet.MARKUP_STYLER_TAG},{});
                styler.addRule(markupStyle,visibleDescSelector);

                hiddenDescSelector=diagram.style.DescendantSelector({SLStudio.MarkupStyleSheet.MARKUP_HIDDEN_STYLER_TAG},{},{SLStudio.MarkupStyleSheet.MARKUP_STYLER_TAG},{});
                styler.addRule(hiddenStyle,hiddenDescSelector);

            end

            if(markupVisible)
                styler.removeClass(bdHandle,SLStudio.MarkupStyleSheet.MARKUP_HIDDEN_STYLER_TAG);
                styler.applyClass(bdHandle,SLStudio.MarkupStyleSheet.MARKUP_VISIBLE_STYLER_TAG);
            else
                styler.removeClass(bdHandle,SLStudio.MarkupStyleSheet.MARKUP_VISIBLE_STYLER_TAG);
                styler.applyClass(bdHandle,SLStudio.MarkupStyleSheet.MARKUP_HIDDEN_STYLER_TAG);
            end

        end

    end
end