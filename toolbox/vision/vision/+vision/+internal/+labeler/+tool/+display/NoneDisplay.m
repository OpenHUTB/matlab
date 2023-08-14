



classdef NoneDisplay<vision.internal.labeler.tool.display.Display

    properties(Dependent,Access=protected)
ShapeLabelers
SupprtedLabelers
    end

    properties
        IsCuboidSupported=false;
        IsPixelSupported=false;
    end

    properties(Access=private)
        TextLabelFontSize=8;
        figWidth;
ToolType
    end

    methods

        function this=NoneDisplay(hFig,toolType,nameDisplayedInTab)

            this=this@vision.internal.labeler.tool.display.Display(hFig,nameDisplayedInTab);
            this.ToolType=toolType;
            deferredInitialization(this);



        end


        function configure(varargin)
        end
    end




    methods(Access=protected)


        function initialize(this)
            this.OrigFigUnit=this.Fig.Units;


            this.Fig.Resize='on';
            this.Fig.Tag='NoneDisplay';


            this.Fig.BusyAction='cancel';
            this.Fig.Interruptible='off';
            this.Fig.Color=this.ColorBeige;
            this.figWidth=this.Fig.Position(3);











        end

        function deferredInitialization(this)

            videoHelperTextHandle=showHelperText(this,getMessage(this),[0.005,0.03,0.8,0.9]);



            setVideoHelperTextInfo(this,videoHelperTextHandle);

        end


        function setVideoHelperTextInfo(this,displayText)
            this.TextLabel=displayText;
            this.TextLabelFontSize=displayText.FontSize;
        end




        function drawImage(varargin)
        end

    end

    methods(Access=private)

        function msg=getMessage(this)

            switch this.ToolType

            case vision.internal.toolType.ImageLabeler
                msg=vision.getMessage('vision:labeler:VideoHelperTextIL');
            case vision.internal.toolType.VideoLabeler
                msg=vision.getMessage('vision:labeler:VideoHelperTextVL');
            case vision.internal.toolType.GroundTruthLabeler
                msg=vision.getMessage('vision:labeler:VideoHelperTextGTL');
            case vision.internal.toolType.LidarLabeler
                msg=vision.getMessage('vision:labeler:VideoHelperTextLL');
            otherwise
                msg=vision.getMessage('vision:labeler:VideoHelperTextGTL');
            end
        end

    end
end
