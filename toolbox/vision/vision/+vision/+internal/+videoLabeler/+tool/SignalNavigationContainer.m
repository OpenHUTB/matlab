


classdef SignalNavigationContainer<handle
    properties
FigHandle
Xoffset
XposImagePanel
TimePanel
SliderPanel
NavControlContainerPanel
OrigFigUnit
RangeSliderObj
    end

    properties(Access=private)
        Y_OFFSET=2;
        TEST_MODE=false;
        X_MARGIN=2;
        FLAG_WIDTH=8;
        DEFAULT_BGCOLOR=[0.9412,0.9412,0.9412];
        figWidth;
        figHeight;
        isDisplayIndex=0;
        TextLabel;
        TextLabelFontSize=8;
    end

    methods

        function obj=SignalNavigationContainer(parent)

            obj.FigHandle=parent;
            OrigFigUnit=get(parent,'units');
            set(parent,'units','pixels');
            contPos=get(parent,'position');
            contW=contPos(3);
            contH=contPos(4);

            obj.Xoffset=obj.X_MARGIN+obj.FLAG_WIDTH;
            obj.XposImagePanel=obj.Xoffset;







            params.parent=parent;
            w=contW-2*obj.Xoffset;
            h=contH-2*obj.Y_OFFSET;
            pos=[2,2,w+204,h+80];
            params.position=pos;
            if obj.TEST_MODE
                params.backgroundColor=obj.DEFAULT_BGCOLOR-0.4;
                params.borderWidth=1;
                params.highlightColor=[0.5,0.5,0.5];
            else
                params.backgroundColor=obj.DEFAULT_BGCOLOR;
                params.borderWidth=1;
                params.highlightColor=obj.DEFAULT_BGCOLOR;
            end

            obj.NavControlContainerPanel=createPanel(params);
            set(obj.NavControlContainerPanel,'units','normalized');


            timePanelH=50;

            sliderPanelH=40;
            clearanceV=2;
            timePanelY=clearanceV;
            sliderPanelY=timePanelY+timePanelH+clearanceV;



            params.parent=obj.NavControlContainerPanel;
            params.position=[1,timePanelY,pos(3),timePanelH];
            if obj.TEST_MODE
                params.backgroundColor=obj.DEFAULT_BGCOLOR-0.03;
                params.highlightColor=obj.DEFAULT_BGCOLOR-0.1;
            else
                params.backgroundColor=obj.DEFAULT_BGCOLOR;
                params.highlightColor=obj.DEFAULT_BGCOLOR;
            end
            params.borderWidth=0;
            obj.TimePanel=createPanel(params);
            obj.TimePanel.BorderType='None';




            params.parent=obj.NavControlContainerPanel;
            params.position=[1,sliderPanelY,pos(3),sliderPanelH];
            if obj.TEST_MODE
                params.backgroundColor=obj.DEFAULT_BGCOLOR-0.03;
                params.highlightColor=obj.DEFAULT_BGCOLOR-0.1;
            else
                params.backgroundColor=obj.DEFAULT_BGCOLOR;
                params.highlightColor=obj.DEFAULT_BGCOLOR;
            end
            params.borderWidth=0;

            obj.SliderPanel=createPanel(params);
            obj.SliderPanel.BorderType='None';

            set(parent,'ResizeFcn',@obj.resizeFigureCallback)

            set(parent,'units',OrigFigUnit);



            obj.FigHandle.AutoResizeChildren='off';
            obj.TimePanel.AutoResizeChildren='off';
            obj.NavControlContainerPanel.AutoResizeChildren='off';
            obj.SliderPanel.AutoResizeChildren='off';
        end

        function obj=setRangeSlider(obj,RangeSliderObj)
            obj.RangeSliderObj=RangeSliderObj;
        end

        function resizeTimePanel(obj,posParent)
            pos=get(obj.TimePanel,'position');
            pos(3)=posParent(3);
            set(obj.TimePanel,'position',pos);
        end

        function resizeSliderPanel(obj,posParent)
            if~isempty(obj.RangeSliderObj)
                pos=get(obj.SliderPanel,'position');
                pos(3)=posParent(3);
                set(obj.SliderPanel,'position',pos);
                obj.RangeSliderObj.resizeSliderPanelForFig(posParent(3));
            end
        end


        function freezeSignalNavInteractions(this)
            disableRangeSlider(this.RangeSliderObj);
        end


        function unfreezeSignalNavInteractions(this)
...
...
...
...
...
...
...
        end


        function resizeFigureCallback(obj,~,~)


            set(obj.NavControlContainerPanel,'position',[0,0,1,1])

            parent=obj.NavControlContainerPanel;
            origFigUnitTmp=get(parent,'units');
            set(parent,'units','pixels');
            posParent=get(parent,'position');

            resizeTimePanel(obj,posParent);
            resizeSliderPanel(obj,posParent);
            set(parent,'units',origFigUnitTmp);
        end
    end
end

function hPanel=createPanel(params)
    if~useAppContainer
        hPanel=uipanel('parent',params.parent,...
        'Units','pixels',...
        'backgroundColor',params.backgroundColor,...
        'borderWidth',params.borderWidth,...
        'Position',params.position,...
        'BorderType','Line',...
        'HighlightColor',params.highlightColor,...
        'Visible','on');
    else
        hPanel=uipanel('parent',params.parent,...
        'backgroundColor',params.backgroundColor,...
        'Position',params.position,...
        'BorderType','Line',...
        'Visible','on',...
        'AutoResizeChildren','off');
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end


