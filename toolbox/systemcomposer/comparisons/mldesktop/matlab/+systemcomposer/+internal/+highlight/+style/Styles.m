classdef Styles<handle

    methods(Static)

        function style=get(styleType)
            import sldiff.internal.highlight.style.*
            import comparisons.internal.colorutil.*
            style=diagram.style.Style;
            switch styleType.StyleClass
            case StyleType.Inserted.StyleClass
                fillColor=toRGBADouble(Colors.rightColor());
                strokeColor=toRGBADouble(Colors.richRightColor());
            case StyleType.Deleted.StyleClass
                fillColor=toRGBADouble(Colors.leftColor());
                strokeColor=toRGBADouble(Colors.richLeftColor());
            case StyleType.Modified.StyleClass
                fillColor=toRGBADouble(Colors.modifiedColor());
                strokeColor=toRGBADouble(Colors.richModifiedColor());
            case StyleType.Base.StyleClass
                fillColor=[243,233,209,255]./255;
                strokeColor=[195,145,25,255]./255;
            case StyleType.Mine.StyleClass
                fillColor=[219,242,252,255]./255;
                strokeColor=[75,190,240,255]./255;
            case StyleType.Theirs.StyleClass
                fillColor=[229,213,232,255]./255;
                strokeColor=[125,45,140,255]./255;
            case StyleType.Conflicted.StyleClass
                fillColor=[250,216,214,255]./255;
                strokeColor=[225,63,42,255]./255;
            case StyleType.ModifiedChildren.StyleClass
                fillColor=[210,210,210,255]./255;
                strokeColor=[0,0,0,1.0];
            otherwise
                return;
            end
            style.set('FillColor',fillColor);
            style.set('FillStyle','Solid');
            style.set('StrokeStyle','SolidLine');
            style.registerProperty('ParentComponentHeaderColor','Color');
            style.set('ParentComponentHeaderColor',fillColor);
            style.registerProperty('CompositionDiagramBodyColor','Color');
            style.set('CompositionDiagramBodyColor',[1,1,1,1.0]);
            style.registerProperty('CompositionSegmentColor','Color');
            style.set('CompositionSegmentColor',strokeColor);
        end


        function HighlightedStyle=highlighted()
            HighlightedStyle=diagram.style.Style;
            stroke=MG2.Stroke;
            stroke.Color=[0.98,0.92,0.2,1.0];
            stroke.Width=4;
            stroke.CapStyle='FlatCap';
            stroke.JoinStyle='RoundJoin';
            stroke.ScaleFunction='SelectionNonLinear';
            HighlightedStyle.set('Trace',MG2.TraceEffect(stroke,'Outer'));
        end


        function noGreyStyle=noGreyStyle()

            noGreyStyle=diagram.style.Style;
            noGreyStyle.set('Opacity',1);
            noGreyStyle.set('FillColor',[210,210,210,255]./255);
        end


        function whiteBGStyle=whiteBGStyle()
            whiteBGStyle=diagram.style.Style;
            whiteBGStyle.set('FillColor',[255,255,255,255]./255);
            whiteBGStyle.set('Opacity',1);
        end


        function greyBDStyle=greyBDStyle()
            greyOutBackgroundColor=[0.95,0.95,0.95];

            greyBDStyle=diagram.style.Style;
            diagram.style.Style.registerProperty('GreyEverything','bool');
            diagram.style.Style.registerProperty('Wash','Color');

            greyBDStyle.set('Wash',greyOutBackgroundColor,'simulink.Graph');
            greyBDStyle.set('GreyEverything',true);
        end


        function slGreyEverythingStyle=slGreyEverythingStyle()
            greyOutOpacity=.2;
            slGreyEverythingStyle=diagram.style.Style;

            slGreyEverythingStyle.set('FillColor',[210,210,210,255]./255);
            slGreyEverythingStyle.set('StrokeColor',[0,0,0,1.0]);
            slGreyEverythingStyle.registerProperty('CompositionSegmentColor','Color');
            slGreyEverythingStyle.set('CompositionSegmentColor',[168,168,168,255]./255);
            slGreyEverythingStyle.set('StrokeStyle','SolidLine');
            slGreyEverythingStyle.set('Opacity',greyOutOpacity);
            slGreyEverythingStyle.set('Glow',[]);
        end
    end

end


function rgba=toRGBADouble(color)
    rgba=[double(color)/255,1];
end
