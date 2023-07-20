


classdef SignalNavigationContainer<handle
    properties
FigHandle
Xoffset
XposImagePanel


NavControlContainerPanel
OrigFigUnit
BrowserPanelObj
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

        function this=SignalNavigationContainer(fig)

            this.FigHandle=fig;
            set(fig,'units','normalized');

...
...
...
...







            params.parent=fig;
            params.unit='normalized';
            params.position=[0,0,1,1];
            if this.TEST_MODE
                params.backgroundColor=this.DEFAULT_BGCOLOR-0.4;
                params.borderWidth=1;
                params.highlightColor=[0.5,0.5,0.5];
            else
                params.backgroundColor=this.DEFAULT_BGCOLOR;
                params.borderWidth=1;
                params.highlightColor=this.DEFAULT_BGCOLOR;
            end

            this.NavControlContainerPanel=createPanel(params);


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

            set(fig,'ResizeFcn',@this.resizeFigureCallback);
            addlistener(fig,'WindowMousePress',@(varargin)this.doDispatchToCorrectPanel(varargin{:}));



        end

        function this=setBrowserPanel(this,BrowserPanelObj)
            this.BrowserPanelObj=BrowserPanelObj;
        end







        function resizeBrowserPanel(this)
            if~isempty(this.BrowserPanelObj)


                this.BrowserPanelObj.resizeBrowserPanelForFig();
            end
        end


        function freezeSignalNavInteractions(this)
            disableBrowserPanel(this.BrowserPanelObj);
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


        function resizeFigureCallback(this,~,~)





            panel=this.NavControlContainerPanel;
            set(panel,'units','normalized');
            set(panel,'position',[0,0,1,1]);
            resizeBrowserPanel(this);

...
...
...
...
...
...
...
...
...
...
...
...
        end
    end

    methods(Access=private)


        function doDispatchToCorrectPanel(this,varargin)



            eventObj=varargin{2};
            if~isprop(eventObj,'HitObject')

                return;
            end


            selectedObject=eventObj.HitObject;

            if isa(selectedObject,'matlab.graphics.GraphicsPlaceholder')
                return
            else
                parent=selectedObject.Parent;
            end

            if isa(parent,'matlab.graphics.GraphicsPlaceholder')
                return
            else

                haveSomethingToDispatch=true;


                while~(strcmp(getTag(parent),'Browser')||...
                    strcmp(getTag(parent),'ImageLabelerImageAxes'))

                    if isa(parent,'matlab.graphics.GraphicsPlaceholder')

                        haveSomethingToDispatch=false;
                        break
                    end
                    if isa(parent,'matlab.ui.Figure')


                        haveSomethingToDispatch=false;
                        break
                    end
                    parent=parent.Parent;
                end
            end

            if haveSomethingToDispatch


                if strcmp(getTag(parent),'Browser')
                    doMouseButtonDownFcn(this.BrowserPanelObj,varargin{:});
                elseif strcmp(getTag(parent),'ImageLabelerImageAxes')

                else
                    assert(0,'Unknown Tag');
                end
            end


            function t=getTag(x)
                if isa(x,'matlab.graphics.GraphicsPlaceholder')
                    t='';
                else
                    t=x.Tag;
                end
            end
        end
    end
end

function hPanel=createPanel(params)
    hPanel=uipanel('parent',params.parent,...
    'Units',params.unit,...
    'backgroundColor',params.backgroundColor,...
    'Position',params.position,...
    'BorderType','Line',...
    'Visible','on');
    if~useAppContainer
        set(hPanel,'BorderWidth',params.borderWidth);
        set(hPanel,'HighlightColor',params.highlightColor);
    else
        set(hPanel,'AutoResizeChildren','off');
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
