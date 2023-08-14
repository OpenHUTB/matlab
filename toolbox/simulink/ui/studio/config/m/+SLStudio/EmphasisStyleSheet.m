




classdef EmphasisStyleSheet<handle
    properties(Constant)
        HIGHLIGHT_STYLER_NAME='MathWorks.HighlightSignalStyler';
        HIGHLIGHT_STYLER_TAG='hiliteTag';
        BD_HIGHLIGHT_STYLER_TAG='bdhiliteTag';
    end



    methods(Static)

        function applyStyler(bdHandle,elements)


            elements=unique(elements);

            instanceData=SLStudio.EmphasisStyleSheet.getInstanceData;

            styler=diagram.style.getStyler(SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_NAME);

            if(isempty(styler))
                diagram.style.createStyler(SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_NAME);
                styler=diagram.style.getStyler(SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_NAME);

                diagram.style.Style.registerProperty('HilightToSrcOrDest','bool');
                diagram.style.Style.registerProperty('SFExternalFillColorId','Color');
                greyEverythingStyle=diagram.style.Style;
                greyEverythingStyle.set('FillColor',[0.7,0.7,0.7,1.0]);
                greyEverythingStyle.set('SFExternalFillColorId',[0.7,0.7,0.7,1.0]);
                greyEverythingStyle.set('FillStyle','Solid');
                greyEverythingStyle.set('StrokeColor',[0.2,0.2,0.2,1.0]);
                greyEverythingStyle.set('TextColor',[0.2,0.2,0.2,1.0]);
                greyEverythingStyle.set('Shadow',[]);
                greyEverythingStyle.set('HilightToSrcOrDest',true);

                greyAllSimulinkSelector=diagram.style.DescendantSelector({SLStudio.EmphasisStyleSheet.BD_HIGHLIGHT_STYLER_TAG},{},{},{'simulink'});
                styler.addRule(greyEverythingStyle,greyAllSimulinkSelector);

                greyAllStateflowSelector=diagram.style.DescendantSelector({SLStudio.EmphasisStyleSheet.BD_HIGHLIGHT_STYLER_TAG},{},{},{'stateflow'});
                styler.addRule(greyEverythingStyle,greyAllStateflowSelector);

                classSelectorBDGrey=diagram.style.ClassSelector(SLStudio.EmphasisStyleSheet.BD_HIGHLIGHT_STYLER_TAG);
                styler.addRule(greyEverythingStyle,classSelectorBDGrey);

                styleHighlighter=diagram.style.Style;
                styleHighlighter.set('StrokeColor',[0,0,0,1],'simulink.Block');
                styleHighlighter.set('StrokeColor',[0,0,0,1],'simulink.Segment');
                styleHighlighter.set('StrokeStyle','SolidLine','simulink.Block');
                styleHighlighter.set('StrokeStyle','SolidLine','simulink.Segment');
                styleHighlighter.set('FillColor',[1,1,1,1],'simulink.Block');
                styleHighlighter.set('FillColor',[1,1,1,1],'simulink.Segment');

                styleHighlighter.set('Shadow',MG2.ShadowEffect(1.0,10,[0,0],false),'simulink.Block');
                styleHighlighter.set('Shadow',MG2.ShadowEffect(1.0,10,[0,0],false),'simulink.Segment');

                stroke=MG2.Stroke;
                stroke.Color=[0.98,0.92,0.2,1.0];
                stroke.Width=4;
                stroke.JoinStyle='RoundJoin';
                stroke.ScaleFunction='SelectionNonLinear';
                styleHighlighter.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Block');
                stroke.Width=2;
                styleHighlighter.set('Trace',MG2.TraceEffect(stroke,'Outer'),'simulink.Segment');

                styler.addRule(styleHighlighter,diagram.style.MultiSelector({SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_TAG},{'Editor'}));
                styler.addRule(styleHighlighter,diagram.style.MultiSelector({SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_TAG},{'Transparency'}));
                styler.addRule(styleHighlighter,diagram.style.MultiSelector({SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_TAG},{'Printing'}));

                selectionBlockHighlighter=diagram.style.Style;
                selectionBlockHighlighter.set('StrokeColor',[0.722,0.839,0.996,0.8]);
                selectionBlockHighlighter.set('StrokeWidth',3);

                selectionModifierSelector=diagram.style.MultiSelector({'MathWorks.GLUE2Styler:Selected',SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_TAG},{'Editor'});
                styler.addRule(selectionBlockHighlighter,selectionModifierSelector);

            end

            thisbdElements=cell(size(elements));

            ii=1;
            for n=1:numel(elements)
                elementbdHandle=get_param(bdroot(get_param(elements(n),'Parent')),'Handle');
                if elementbdHandle==bdHandle
                    obj=diagram.resolver.resolve(elements(n));
                    thisbdElements(ii)={obj};
                    styler.applyClass(obj,SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_TAG);
                    ii=ii+1;
                end
            end






            if ii<=numel(thisbdElements)
                thisbdElements(ii:numel(thisbdElements))=[];
            end

            instanceData.bd2HighlightedElements(bdHandle)=thisbdElements;

            styler.applyClass(bdHandle,SLStudio.EmphasisStyleSheet.BD_HIGHLIGHT_STYLER_TAG);

        end

        function removeStyler(bdHandle)



            instanceData=SLStudio.EmphasisStyleSheet.getInstanceData;

            if isempty(instanceData.bd2HighlightedElements)
                return;
            end

            if~isKey(instanceData.bd2HighlightedElements,bdHandle)
                return;
            end

            elements=instanceData.bd2HighlightedElements(bdHandle);

            styler=diagram.style.getStyler(SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_NAME);
            styler.removeClass(elements,SLStudio.EmphasisStyleSheet.HIGHLIGHT_STYLER_TAG);
            styler.removeClass(bdHandle,SLStudio.EmphasisStyleSheet.BD_HIGHLIGHT_STYLER_TAG);

            remove(instanceData.bd2HighlightedElements,bdHandle);

        end

    end

    methods(Static,Access=private)

        function data=getInstanceData
            persistent instanceData

            if isempty(instanceData)
                instanceData.bd2HighlightedElements=containers.Map('KeyType','double','ValueType','any');
            end

            data=instanceData;
        end

    end

end

