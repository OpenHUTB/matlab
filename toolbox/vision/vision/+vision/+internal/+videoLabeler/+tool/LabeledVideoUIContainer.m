


classdef LabeledVideoUIContainer<handle
    properties
FigHandle
Xoffset
XposImagePanel
ImagePanel
LoadingPanel
LoadingText
SignalContainerPanel
OrigFigUnit
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


    end

    methods

        function obj=LabeledVideoUIContainer(parent)

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
            pos=[2,2,w+204,h+3];
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

            obj.SignalContainerPanel=createPanel(params);
            set(obj.SignalContainerPanel,'units','normalized');


            clearanceV=2;
            imagePanelY=clearanceV;
            imagePanelH=pos(4)-imagePanelY-clearanceV;




            params.parent=parent;
            w=pos(3)-2*obj.Xoffset;
            params.position=[obj.Xoffset,imagePanelY,w,imagePanelH];
            if obj.TEST_MODE
                params.backgroundColor=[0.5,0.5,0];
                params.highlightColor=[0.5,0.5,0.5];
            else
                params.backgroundColor=obj.DEFAULT_BGCOLOR;
                params.highlightColor=obj.DEFAULT_BGCOLOR;
            end
            params.borderWidth=0;

            obj.ImagePanel=createPanel(params);
            createLoadingPanel(obj);

            obj.figWidth=obj.FigHandle.Position(3);
            obj.figHeight=obj.FigHandle.Position(4);

            set(parent,'ResizeFcn',@obj.resizeFigureCallback)

            set(parent,'units',OrigFigUnit);
        end

        function obj=repositionLoadingText(obj,posImagePanel)
            pos=get(obj.LoadingPanel,'position');
            pos(1)=posImagePanel(3)/2-pos(3)/2;
            pos(2)=posImagePanel(4)/2-pos(4)/2;
            set(obj.LoadingPanel,'position',pos);
        end

        function resizeImagePanel(obj,posParent)
            posImagePanel=get(obj.ImagePanel,'position');
            posImagePanel(3)=max(posParent(3)-2*posImagePanel(1),1);
            posImagePanel(4)=max(posParent(4)-posImagePanel(2),1);
            set(obj.ImagePanel,'position',posImagePanel);
            repositionLoadingText(obj,posImagePanel);
        end































        function resizeFigureCallback(obj,~,~)

            set(obj.SignalContainerPanel,'position',[0,0,1,1])

            parent=obj.SignalContainerPanel;
            origFigUnitTmp=get(parent,'units');
            set(parent,'units','pixels');
            posParent=get(parent,'position');

            resizeImagePanel(obj,posParent);
            set(parent,'units',origFigUnitTmp);

        end


        function getDisplayIndexInfo(obj,flag)
            obj.isDisplayIndex=flag;
        end


        function setLoadingText(obj,flag,isVideo)
            if flag
                status='on';
                if isVideo
                    obj.LoadingText.String='Loading Video ...';
                else
                    obj.LoadingText.String='Loading Images ...';
                end
            else
                status='off';
            end
            set(obj.LoadingPanel,'visible',status);
            set(obj.LoadingText,'visible',status);
        end


        function createLoadingPanel(obj)

            bgColor=[0.7,0.7,0.7];
            if ispc
                w=350;
            elseif ismac
                w=300;
            else
                w=400;
            end
            if~useAppContainer
                obj.LoadingPanel=uipanel('parent',obj.ImagePanel,...
                'Units','pixels',...
                'backgroundColor',bgColor,...
                'borderWidth',1,...
                'Position',[100,100,w,100],...
                'BorderType','Line',...
                'HighlightColor',[0.8,0.8,0.8],...
                'Visible','off');
            else
                obj.LoadingPanel=uipanel('parent',obj.ImagePanel,...
                'Units','pixels',...
                'backgroundColor',bgColor,...
                'Position',[100,100,w,100],...
                'BorderType','Line',...
                'Visible','off');
            end

            obj.LoadingText=uicontrol('parent',obj.LoadingPanel,...
            'units','pixels',...
            'position',[50,20,w-50,50],...
            'backgroundColor',bgColor,...
            'FontSize',24,...
            'FontWeight','bold',...
            'HorizontalAlignment','left',...
            'foregroundcolor',[1,1,1],...
            'Style','text',...
            'String','Loading Video...',...
            'Visible','off');
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
        hPanel=uipanel('Parent',params.parent,...
        'Units','pixels',...
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