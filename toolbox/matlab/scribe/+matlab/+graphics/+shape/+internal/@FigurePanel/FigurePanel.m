classdef(ConstructOnLoad,Sealed)FigurePanel<matlab.ui.container.internal.UIContainer





    properties(Constant,Transient,Access=private)
        TitleHeight=14;
        TextHeightBorder=2;
        TextWidthBorder=6;
    end

    properties(Access=private,Transient,NonCopyable)

        Frame;
        TitleBar;
        TextField;
        CloseButton;


        FigureSizeChangedListener=event.listener.empty;


        PositionChangedListener=event.listener.empty;


        SizeCache=[0,0];


        RelativePosition=[0,0,0,0];
    end

    properties(Access=private)
        NumButtonsDown=0;
    end

    properties(Access=public)
        Title='Default Title';
        String='Default Text';
    end

    events


Hit
    end

    methods
        function set.String(hObj,newValue)
            hObj.String=newValue;


            hObj.TextField.String=newValue;


            hObj.doAutoSize;
        end

        function set.Title(hObj,newValue)
            hObj.Title=newValue;


            hObj.TitleBar.String=newValue;
        end

        function hObj=FigurePanel(varargin)

            hObj@matlab.ui.container.internal.UIContainer(...
            'Units','pixels',...
            'Position',[1,1,200,60]);


            origVis=hObj.Visible;
            hObj.Visible='off';

            hObj.Frame=matlab.ui.control.UIControl('Parent',hObj,...
            'Serializable','off',...
            'Style','frame',...
            'Units','pixels',...
            'BackgroundColor',[1,1,1],...
            'Tag','figpanel: frame',...
            'Enable','inactive',...
            'Interruptible','off',...
            'HandleVisibility','off',...
            'HitTest','off',...
            'Internal',true);

            hObj.TitleBar=matlab.ui.control.UIControl('Parent',hObj,...
            'Serializable','off',...
            'Style','text',...
            'Units','pixels',...
            'ForegroundColor',[1,1,1],...
            'BackgroundColor',[.4,.4,.5],...
            'HorizontalAlignment','center',...
            'ButtonDownFcn',@localTitleClick,...
            'UIContextMenu',hObj.UIContextMenu,...
            'Enable','inactive',...
            'Interruptible','off',...
            'FontName','Sans Serif',...
            'FontSize',8,...
            'Tag','figpanel: title bar',...
            'String',hObj.Title,...
            'HandleVisibility','off',...
            'Internal',true);

            hObj.TextField=matlab.ui.control.UIControl('Parent',hObj,...
            'Serializable','off',...
            'Style','text',...
            'Units','pixels',...
            'ForegroundColor',[0,0,0],...
            'BackgroundColor',[1,1,1],...
            'HorizontalAlignment','left',...
            'Tag','figpanel: text field',...
            'String',hObj.String,...
            'FontName','Sans Serif',...
            'Enable','inactive',...
            'Interruptible','off',...
            'HandleVisibility','off',...
            'HitTest','off',...
            'Internal',true);

            hObj.CloseButton=matlab.ui.control.UIControl('Parent',hObj,...
            'Serializable','off',...
            'Style','pushbutton',...
            'Units','pixels',...
            'FontName','Helvetica',...
            'FontSize',10,...
            'String','X',...
            'Callback',@(obj,evd)(delete(hObj)),...
            'Interruptible','off',...
            'Tag','figpanel: close button',...
            'HandleVisibility','off',...
            'Internal',true);

            hObj.Visible=origVis;


            addlistener(hObj,'SizeChanged',@hObj.layoutContents);


            addlistener(hObj,'Parent','PostSet',@hObj.doSetParent);
            hObj.doSetParent;


            addlistener(hObj,'UIContextMenu','PostSet',@hObj.doSetUIContextMenu);


            hObj.PositionChangedListener=...
            addlistener(hObj,'LocationChanged',@hObj.updateLocationCache);

            addlistener([hObj,hObj.TitleBar,hObj.CloseButton],'ButtonDown',@hObj.doButtonDown);

            if nargin
                set(hObj,varargin{:});
            end

            function localTitleClick(~,~)

                hFig=ancestor(hObj,'figure');
                if~strcmp(hFig.SelectionType,'normal')
                    return
                end



                origPositionPixels=hgconvertunits(hFig,hObj.Position,hObj.Units,'pixels',hObj.Parent);

                mousePosition=hFig.CurrentPoint;
                mousePosition=hgconvertunits(hFig,[mousePosition,0,0],hFig.Units,'pixels',hFig);
                origMouseXYPixels=mousePosition(1:2);



                hMotionListener=addlistener(hFig,'WindowMouseMotion',@localTitleMotion);
                hUpListener=addlistener(hFig,'WindowMouseRelease',@localTitleUp);

                function localTitleMotion(hFig,evd)

                    if~isvalid(hObj)
                        return
                    end


                    newMouseXYPixels=evd.Point;
                    if~strcmp(hFig.Units,'pixels')
                        newMousePositionPixels=hgconvertunits(hFig,[newMouseXYPixels,0,0],hFig.Units,'pixels',hFig);
                        newMouseXYPixels=newMousePositionPixels(1:2);
                    end

                    mouseXYDelta=newMouseXYPixels-origMouseXYPixels;
                    newPositionPixels=origPositionPixels+[mouseXYDelta,0,0];



                    newPositionPixels=limitToContainerSize(newPositionPixels,hObj.Parent);


                    oldUnits=hObj.Units;
                    hObj.Units='pixels';
                    hObj.Position=newPositionPixels;
                    hObj.Units=oldUnits;
                end


                function localTitleUp(~,~)

                    delete(hMotionListener);
                    delete(hUpListener);
                end
            end
        end
    end

    methods(Access=private)
        function doSetParent(hObj,~,~)

            hObj.updateLocationCache;
            hObj.layoutContents;
            if~isempty(hObj.Parent)
                hObj.FigureSizeChangedListener=event.listener(hObj.Parent,'SizeChanged',@hObj.doParentSizeChange);
            else
                hObj.FigureSizeChangedListener=event.listener.empty;
            end


            hFig=ancestor(hObj,'figure');
            if~isempty(hFig)&&matlab.ui.internal.isUIFigure(hFig)
                hObj.CloseButton.FontSize=7;
            end
        end

        function doSetUIContextMenu(hObj,~,~)

            hObj.TitleBar.UIContextMenu=hObj.UIContextMenu;
        end

        function doButtonDown(hObj,~,~)

            hObj.notify('Hit');
        end


        function doParentSizeChange(hObj,hParent,~)

            if~isvalid(hObj)
                return;
            end
            hFig=ancestor(hParent,'figure');
            if isempty(hFig)||~isvalid(hFig)
                return;
            end


            pixPosition=hgconvertunits(hFig,hObj.Position,hObj.Units,'pixels',hParent);
            figPos=hgconvertunits(hFig,hParent.Position,hParent.Units,'pixels',hParent.Parent);

            relativePosition=hObj.RelativePosition;
            if relativePosition(1)<=1-relativePosition(2)

                pixPosition(1)=figPos(3)*relativePosition(1);
                pixPosition(1)=max(1,pixPosition(1));
            else

                pixPosition(1)=figPos(3)*relativePosition(2)-pixPosition(3);
                pixPosition(1)=min(figPos(3)-pixPosition(3),pixPosition(1));
            end

            if relativePosition(3)<=1-relativePosition(4)

                pixPosition(2)=figPos(4)*relativePosition(3);
                pixPosition(2)=max(1,pixPosition(2));
            else

                pixPosition(2)=figPos(4)*relativePosition(4)-pixPosition(4);
                pixPosition(2)=min(figPos(4)-pixPosition(4),pixPosition(2));
            end





            hObj.PositionChangedListener.Enabled=false;
            hObj.Position=hgconvertunits(hFig,pixPosition,'pixels',hObj.Units,hParent);
            hObj.PositionChangedListener.Enabled=true;
        end


        function updateLocationCache(hObj,~,~)
            hParent=hObj.Parent;
            hFig=ancestor(hObj,'Figure');
            if isempty(hFig)||~isvalid(hFig)
                return;
            end
            pixPosition=hObj.Position;
            if~strcmp(hObj.Units,'pixels')
                pixPosition=hgconvertunits(hFig,pixPosition,hObj.Units,'pixels',hParent);
            end

            parentPos=hParent.Position;
            if~strcmp(hParent.Units,'pixels')
                parentPos=hgconvertunits(hFig,parentPos,hParent.Units,'pixels',hParent.Parent);
            end

            frameLeft=pixPosition(1)/parentPos(3);
            frameBot=pixPosition(2)/parentPos(4);
            frameRight=(pixPosition(1)+pixPosition(3))/parentPos(3);
            frameTop=(pixPosition(2)+pixPosition(4))/parentPos(4);
            hObj.RelativePosition=[frameLeft,frameRight,frameBot,frameTop];
        end


        function doAutoSize(hObj)
            hParent=hObj.Parent;
            hFig=ancestor(hObj,'figure');

            if isempty(hFig)||~isvalid(hFig)
                return;
            end


            pixelPosition=hgconvertunits(hFig,hObj.Position,hObj.Units,'pixels',hParent);


            minHeight=45;
            minWidth=200;
            strExt=get(hObj.TextField,'Extent');
            string_height=ceil(max(minHeight,strExt(4)));
            string_width=ceil(max(minWidth,strExt(3)));



            newPanelHeight=string_height+hObj.TitleHeight+hObj.TextHeightBorder;
            heightChange=pixelPosition(4)-newPanelHeight;

            newPanelWidth=string_width+hObj.TextWidthBorder;

            if(heightChange~=0)||(newPanelWidth~=pixelPosition(3))
                pixelPosition(2)=pixelPosition(2)+heightChange;
                pixelPosition(4)=newPanelHeight;

                pixelPosition(3)=newPanelWidth;


                pixelPosition=limitToContainerSize(pixelPosition,hParent);


                hObj.Position=hgconvertunits(hFig,pixelPosition,'pixels',hObj.Units,hParent);
            end
        end


        function layoutContents(hObj,~,~)

            hParent=hObj.Parent;
            hFig=ancestor(hObj,'figure');

            if isempty(hFig)||~isvalid(hFig)
                return;
            end


            pixelPosition=hgconvertunits(hFig,hObj.Position,hObj.Units,'pixels',hParent);

            if all(hObj.SizeCache==pixelPosition(3:4))

                return
            else
                title_height=hObj.TitleHeight;


                frame_width=pixelPosition(3);
                frame_height=pixelPosition(4);
                hObj.Frame.Position=[1,1,frame_width,frame_height];


                text_x=5;
                text_y=2;
                text_width=frame_width-hObj.TextWidthBorder;
                text_height=frame_height-hObj.TextHeightBorder-title_height;
                hObj.TextField.Position=[text_x,text_y,text_width,text_height];


                button_width=title_height;
                button_height=title_height;
                button_x=text_x+text_width-button_width+1;
                button_y=text_y+text_height;
                hObj.CloseButton.Position=[button_x,button_y,button_width,button_height];


                title_x=2;
                title_y=text_y+text_height;
                title_width=frame_width-2;
                hObj.TitleBar.Position=[title_x,title_y,title_width,title_height];


                hObj.SizeCache=pixelPosition(3:4);
            end
        end
    end
end




function posRect=limitToContainerSize(posRect,hParent)
    if~isempty(hParent)
        containerPosPixels=hParent.Position;
        if~strcmp(hParent.Units,'pixels')
            hFig=ancestor(hParent','figure');
            containerPosPixels=hgconvertunits(hFig,hParent.Position,hParent.Units,'pixels',hParent.Parent);
        end

        posRect(1:2)=max(posRect(1:2),[1,1]);
        if posRect(1)+posRect(3)>containerPosPixels(3)
            posRect(1)=containerPosPixels(3)-posRect(3)+1;
        end
        if posRect(2)+posRect(4)>containerPosPixels(4)
            posRect(2)=containerPosPixels(4)-posRect(4)+1;
        end
    end
end
