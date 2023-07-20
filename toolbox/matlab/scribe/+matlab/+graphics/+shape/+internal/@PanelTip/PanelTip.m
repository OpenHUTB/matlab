classdef(ConstructOnLoad,Sealed)PanelTip<matlab.graphics.shape.internal.TipInfo





    properties

BackgroundAlpha


        BackgroundColor=[1,1,1]


        Color=[0,0,0]


        EdgeColor=[0,0,0]


        FontAngle='normal'


        FontName='Helvetica'


        FontUnits='points'


        FontSize=10


        FontWeight='normal'


        Interpreter='none'


        Position=[0,0,0]


        String=''


        TargetType='';


LocatorSize


        Orientation='topright';


        CurrentTip='off';


        TextFormatHelper matlab.graphics.shape.internal.TextFormatHelper;
    end

    properties(Access=private,Transient)

FigurePanelInterface
    end

    properties(Access=private,Transient,NonCopyable)

        GraphicsTipHandle matlab.graphics.shape.internal.TipInfo;
    end


    methods
        function hObj=PanelTip(varargin)

            if~isempty(varargin)
                set(hObj,varargin{:});
            end
            hObj.TextFormatHelper=matlab.graphics.shape.internal.TextFormatHelper();
        end

        function delete(hObj)

            hFP=hObj.FigurePanelInterface;
            if~isempty(hFP)&&hFP.isValid()
                hFP.removeData(hObj);
            end
        end


        function set.String(hObj,newValue)
            hObj.String=newValue;
            hObj.MarkDirty('all');
        end

        function set.TargetType(hObj,newValue)
            hObj.TargetType=newValue;
            hObj.MarkDirty('all');
        end

        function set.BackgroundColor(hObj,newValue)
            hObj.BackgroundColor=newValue;
            hObj.MarkDirty('all');
        end

        doUpdate(obj,updateState);
    end

    methods(Hidden)


        function setFormattedTextString(hObj,hDescriptors)
            hObj.String=hObj.TextFormatHelper.formatDatatipForStandardStringStrategy(hDescriptors,hObj.FontAngle,true);
        end
    end
end
