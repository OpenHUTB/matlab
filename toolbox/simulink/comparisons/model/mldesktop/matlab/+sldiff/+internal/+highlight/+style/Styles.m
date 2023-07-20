classdef Styles<handle




    methods(Static)

        function style=get(styleType)
            import sldiff.internal.highlight.style.StyleType
            import comparisons.internal.colorutil.Colors
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
                fillColor=[1,1,1,1.0];
                strokeColor=[0,0,0,1.0];
            end

            style=diagram.style.Style;
            style.set('FillColor',fillColor);
            style.set('StrokeColor',strokeColor);
            style.set('FillStyle','Solid');
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

            diagram.style.Style.registerProperty('SFStateOpacity','double');

            HighlightedStyle.set('SFStateOpacity',1,'stateflow.State');
        end

        function noGreyStyle=noGreyStyle()

            noGreyStyle=diagram.style.Style;
            noGreyStyle.set('Opacity',1);

            diagram.style.Style.registerProperty('SFStateOpacity','double');

            noGreyStyle.set('SFStateOpacity',1,'stateflow.State');
        end

        function noGreySegmentStyle=noGreySegmentStyle()
            noGreySegmentStyle=diagram.style.Style;
            noGreySegmentStyle.set('Opacity',1);
        end

        function greyBDStyle=greyBDStyle()
            greyOutBackgroundColor=[0.95,0.95,0.95];

            greyBDStyle=diagram.style.Style;


            diagram.style.Style.registerProperty('GreyEverything','bool');
            diagram.style.Style.registerProperty('SFExternalFillColorId','Color');
            diagram.style.Style.registerProperty('Wash','Color');

            greyBDStyle.set('Wash',greyOutBackgroundColor,'simulink.Graph');
            greyBDStyle.set('Wash',greyOutBackgroundColor,'stateflow.Chart')
            greyBDStyle.set('SFExternalFillColorId',greyOutBackgroundColor);
            greyBDStyle.set('GreyEverything',true);
        end

        function slGreyEverythingStyle=slGreyEverythingStyle()
            greyOutOpacity=.2;






            slGreyEverythingStyle=diagram.style.Style;









            slGreyEverythingStyle.set('Opacity',1,'simulink.SegmentLabel');


            slGreyEverythingStyle.set('Opacity',greyOutOpacity);
            slGreyEverythingStyle.set('Glow',[]);

        end

        function sfGreyEverythingStyle=sfGreyEverythingStyle()
            greyOutOpacity=.2;









            sfGreyEverythingStyle=diagram.style.Style;
            diagram.style.Style.registerProperty('SFStateOpacity','double');
            sfGreyEverythingStyle.set('Opacity',greyOutOpacity,'stateflow.Junction');
            sfGreyEverythingStyle.set('Opacity',greyOutOpacity,'stateflow.Transition');
            sfGreyEverythingStyle.set('SFStateOpacity',greyOutOpacity,'stateflow.State');
            sfGreyEverythingStyle.set('Glow',[]);
        end

    end

end

function rgba=toRGBADouble(color)
    rgba=[double(color)/255,1];
end
