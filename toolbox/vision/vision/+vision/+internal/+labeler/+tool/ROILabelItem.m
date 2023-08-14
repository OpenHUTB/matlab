

classdef ROILabelItem<vision.internal.labeler.tool.ListItem


    properties(Constant)
        MinWidth=185;
        MinHeight=200;
        Shift=180;
        ShiftP=90;
        SelectedBGColor=[0.9882,0.9882,0.8627];
        UnselectedBGColor=[0.94,0.94,0.94];
        ArrowIconW=10;
        EyeIconW=20;
        ArrowAndTextSpaceX=10;
        TextNColorSpaceX=20;
        ROILabelRowRightClearance=10;
        ROIColorAndTypeXSpacing=10;
        ROITextAndColorXSpacing=10;

        ROIColorPanelW=8;
        ROIColorPanelH=16;

        ROITypeIconW=36;
        ROITypeIconH=16;
        RightClearance=10;
        IconHighlightedIntensity=0.4;
    end

    properties
        EyeIconStartX=9;
        ArrowIconStartX=27;
        Index;
        TextStartX;
        MaxTextWidth=200;
        MinROIColorPanelStartX;
        MaxWidthReqForROILabelRow;
        MaxROIColorPanelStartX;
        Panel;

        RightDownArrowPanel;
        EyeOpenClosePanel;



        RightDownArrowImgHnd;

        DownArrowSelectCData;
        DownArrowUnselectCData;

        RightArrowSelectCData;
        RightArrowUnselectCData;


        EyeOpenCloseImgHnd;

        EyeOpenSelectCData;
        EyeOpenUnselectCData;

        EyeCloseSelectCData;
        EyeCloseUnselectCData;


        ROITypeImgHnd;

        RectSelectCData;
        RectUnselectCData;

        LineSelectCData;
        LineUnselectCData;

        PixelLabelSelectCData;
        PixelLabelUnselectCData;

        ProjCuboidSelectCData;
        ProjCuboidUnselectCData;

        PolygonSelectCData;
        PolygonUnselectCData;


        ROIColorPanel;

        ROILabelText;
        ROITypePanel;

        DescriptionTextBox;
        DescriptionEditBox;
        AttributeTextBox;
        AttributeEditBox;

        ItemContextMenu;

        HideAttribute;
        IsExpanded;
        IsDisabled;
        IsSelected;
        IsROIRect;
        Description;
        IsROIChecked;

EditAttributeChildMenuHandles
DeleteAttributeChildMenuHandles

EditAttributeParentMenuHandle
DeleteAttributeParentMenuHandle

EditMenuHanlde
DeleteMenuHanlde

Data


        Visible=true




        IsClicked=false;
    end

    methods
        function this=ROILabelItem(parent,idx,data)

            isALabel=isLabel(this,data);
            isCuboidSupported=isALabel&&data.IsRectCuboid;
            if isALabel
                dispName=data.Label;
            else
                this.ArrowIconStartX=this.ArrowIconStartX+20;
                this.MaxTextWidth=this.MaxTextWidth-20;
                dispName=data.Sublabel;
            end
            setConsDependentProps(this);

            computeDownRightArrowIconsCData(this);
            computeEyeOpenCloseIconsCData(this);
            computeROITypeIconsCData(this,isALabel,isCuboidSupported);

            this.Index=idx;
            this.IsDisabled=false;
            this.IsExpanded=false;
            this.Data=data;
            this.IsROIRect=(data.ROI==labelType.Rectangle);
            this.IsROIChecked=false;

            containerW=getContainerWidth(this,parent);


            panelW=max(this.MinWidth,containerW);
            this.Panel=uipanel('Parent',parent,...
            'Visible','off',...
            'Units','pixels',...
            'BackgroundColor',this.UnselectedBGColor,...
            'Position',[0,0,panelW,28],...
            'ButtonDownFcn',@this.doButtonDownFcn);
            if useAppContainer
                this.Panel.AutoResizeChildren='off';
            end


            EyeIconH=this.EyeIconW;

            this.EyeOpenClosePanel=uipanel('Parent',this.Panel,...
            'Visible','on',...
            'Units','pixels',...
            'BackgroundColor',parent.BackgroundColor,...
            'Position',[this.EyeIconStartX,4,this.EyeIconW,EyeIconH],...
            'BorderType','Line',...
            'Tag','ShowHideLabel');

            if~useAppContainer
                this.EyeOpenClosePanel.HighlightColor=[0.8,0.8,0.8];
            end

            showEyeIconAndSaveHandle(this);


            set(this.EyeOpenCloseImgHnd,'ButtonDownFcn',@this.doROIVisibilityButtonDownFcn);

            if~data.ROIVisibility
                this.EyeOpenCloseImgHnd.CData=this.EyeCloseSelectCData;
                this.IsROIChecked=true;
            end


            ArrowIconH=this.ArrowIconW;
            this.RightDownArrowPanel=uipanel('Parent',this.Panel,...
            'Visible','on',...
            'Units','pixels',...
            'BackgroundColor',parent.BackgroundColor,...
            'BorderType','none',...
            'Position',[this.ArrowIconStartX+5,9,this.ArrowIconW,ArrowIconH]);

            showArrowIconAndSaveHandle(this);


            set(this.RightDownArrowImgHnd,'ButtonDownFcn',@this.doExpandButtonDownFcn);


            textPos=[this.TextStartX+5,0,this.MaxTextWidth,20];
            [roiColorPanelStartX,roiTypePanelStartX]=getROIColorNTypePanelStartX(this,containerW);

            maxTextLenInPixel=roiColorPanelStartX-20-this.ROITextAndColorXSpacing-this.TextStartX;
            fullLabel=dispName;
            shortLabel=vision.internal.labeler.tool.shortenLabel(fullLabel,maxTextLenInPixel);
            this.ROILabelText=uicontrol('Style','text',...
            'Parent',this.Panel,...
            'TooltipString',fullLabel,...
            'String',shortLabel,...
            'Position',textPos,...
            'FontName','Arial',...
            'FontSize',10,...
            'HorizontalAlignment','left',...
            'Enable','inactive',...
            'ButtonDownFcn',@this.doButtonDownFcn);


            this.ROIColorPanel=uipanel('Parent',this.Panel,...
            'Units','pixels',...
            'BorderType','none',...
            'BackgroundColor',data.Color,...
            'Position',[roiColorPanelStartX,6,this.ROIColorPanelW,this.ROIColorPanelH],...
            'ButtonDownFcn',@this.doButtonDownFcn,...
            'Tag','LabelerROIColor');


            this.ROITypePanel=uipanel('Parent',this.Panel,...
            'Units','pixels',...
            'BorderType','none',...
            'BackgroundColor',this.UnselectedBGColor,...
            'Position',[roiTypePanelStartX,6,this.ROITypeIconW,this.ROITypeIconH]);

            showROITypeIconAndSaveHandle(this);


            set(this.ROITypeImgHnd,'ButtonDownFcn',@this.doButtonDownFcn);


            this.Description=data.Description;

            posDTB=[16,this.Shift-20,100,20];
            posDEB=[16,this.Shift-70,this.MinWidth-16,50];
            this.HideAttribute=(this.Data.ROI==labelType.PixelLabel)||...
            isImageLabeler(this,parent);
            if this.HideAttribute
                posDTB(2)=this.ShiftP-20;
                posDEB(2)=this.ShiftP-70;
            end
            this.DescriptionTextBox=uicontrol('Parent',this.Panel,...
            'Style','Text',...
            'String',vision.getMessage('vision:labeler:Description'),...
            'Position',posDTB,...
            'HorizontalAlignment','left',...
            'Enable','inactive',...
            'Visible','off');

            this.DescriptionEditBox=uicontrol('Parent',this.Panel,...
            'Style','edit',...
            'Max',5,...
            'String',this.Description,...
            'Position',posDEB,...
            'HorizontalAlignment','left',...
            'Enable','inactive',...
            'Visible','off');


            this.AttributeTextBox=uicontrol('Parent',this.Panel,...
            'Style','Text',...
            'String',vision.getMessage('vision:labeler:Attribute'),...
            'Position',[16,80,100,20],...
            'HorizontalAlignment','left',...
            'Enable','inactive',...
            'Visible','off');
            this.AttributeEditBox=uicontrol('Parent',this.Panel,...
            'Style','edit',...
            'Max',5,...
            'String',attrib2DisplayString(this,data.AttributeNames),...
            'Position',[16,30,this.MinWidth-16,50],...
            'HorizontalAlignment','left',...
            'Enable','inactive',...
            'Visible','off');


            createDefaultContextMenu(this);
        end

        function createDefaultContextMenu(this)

            panelFigure=ancestor(this.Panel,'Figure');


            this.ItemContextMenu=uicontextmenu(panelFigure);
            this.EditMenuHanlde=uimenu(this.ItemContextMenu,'Label',...
            vision.getMessage('vision:labeler:ContextMenuEditLabel'),...
            'Callback',@this.OnCallbackEditItem);
            this.DeleteMenuHanlde=uimenu(this.ItemContextMenu,'Label',...
            vision.getMessage('vision:labeler:ContextMenuDeleteLabel'),...
            'Callback',@this.OnCallbackDeleteItem);
            this.Panel.UIContextMenu=this.ItemContextMenu;
            this.ROILabelText.UIContextMenu=this.ItemContextMenu;
            this.DescriptionEditBox.UIContextMenu=this.ItemContextMenu;
            this.AttributeEditBox.UIContextMenu=this.ItemContextMenu;

        end

        function setConsDependentProps(this)
            this.TextStartX=this.ArrowIconStartX+this.ArrowIconW+...
            this.ArrowAndTextSpaceX;
            this.MaxROIColorPanelStartX=this.TextStartX+this.MaxTextWidth+...
            this.TextNColorSpaceX;
            this.MaxWidthReqForROILabelRow=this.MaxROIColorPanelStartX+...
            this.ROIColorPanelW+...
            this.ROIColorAndTypeXSpacing+this.ROITypeIconW+...
            this.RightClearance;
            this.MinROIColorPanelStartX=this.MinWidth...
            -this.ROILabelRowRightClearance...
            -this.ROITypeIconW...
            -this.ROIColorAndTypeXSpacing...
            -this.ROIColorPanelW;
        end

        function showArrowIconAndSaveHandle(this)
            hax=axes('Units','normal','Position',[0,0,1,1],'Parent',this.RightDownArrowPanel);
            this.RightDownArrowImgHnd=image(this.RightArrowUnselectCData,'CDataMapping','direct','Parent',hax);
            set(hax,'Visible','off')
            if vision.internal.labeler.jtfeature('useAppContainer')
                hax.Toolbar.Visible='off';
            end
        end

        function showEyeIconAndSaveHandle(this)
            hax=axes('Units','normal','Position',[0,0,1,1],'Parent',this.EyeOpenClosePanel);
            this.EyeOpenCloseImgHnd=image(this.EyeOpenUnselectCData,'CDataMapping','direct','Parent',hax);
            set(hax,'Visible','off')
            if vision.internal.labeler.jtfeature('useAppContainer')
                hax.Toolbar.Visible='off';
            end
        end

        function showROITypeIconAndSaveHandle(this)
            hax=axes('Units','normal','Position',[0,0,1,1],'Parent',this.ROITypePanel);
            roiTypeCdata=getROITypeUnselectedCData(this);
            this.ROITypeImgHnd=image(roiTypeCdata,'CDataMapping','direct','Parent',hax);
            set(hax,'Visible','off')
            if vision.internal.labeler.jtfeature('useAppContainer')
                hax.Toolbar.Visible='off';
            end
        end

        function TF=isLabel(~,data)

            TF=~isprop(data,'LabelName');
        end

        function[roiColorPanelStartX,roiTypePanelStartX]=getROIColorNTypePanelStartX(this,containerW)
            w=containerW;

            if w>this.MinWidth
                if w>this.MaxWidthReqForROILabelRow
                    roiColorPanelStartX=this.MaxROIColorPanelStartX;
                else



                    roiColorPanelStartX=w-this.ROILabelRowRightClearance...
                    -this.ROITypeIconW...
                    -this.ROIColorAndTypeXSpacing...
                    -this.ROIColorPanelW;
                end
            else
                roiColorPanelStartX=this.MinROIColorPanelStartX;
            end

            roiTypePanelStartX=roiColorPanelStartX+...
            this.ROIColorPanelW+...
            this.ROIColorAndTypeXSpacing;
        end


        function modifyMenuLabel(this,isLabel)
            if isLabel
                this.EditMenuHanlde.Label=vision.getMessage('vision:labeler:ContextMenuEditLabel');
                this.DeleteMenuHanlde.Label=vision.getMessage('vision:labeler:ContextMenuDeleteLabel');
            else
                this.EditMenuHanlde.Label=vision.getMessage('vision:labeler:ContextMenuEditSublabel');
                this.DeleteMenuHanlde.Label=vision.getMessage('vision:labeler:ContextMenuDeleteSublabel');
            end
        end


        function containerW=getContainerWidth(~,parent)
            fig=ancestor(parent,'Figure');
            containerW=fig.Position(3);
        end

        function roiTypeCdata=getROITypeSelectedCData(this)

            switch this.Data.ROI
            case labelType.Rectangle
                roiTypeCdata=this.RectSelectCData;
            case labelType.Line
                roiTypeCdata=this.LineSelectCData;
            case labelType.PixelLabel
                roiTypeCdata=this.PixelLabelSelectCData;
            case labelType.ProjectedCuboid
                roiTypeCdata=this.ProjCuboidSelectCData;
            case labelType.Polygon
                roiTypeCdata=this.PolygonSelectCData;
            otherwise
                error('unsupported label type');
            end

        end

        function roiTypeCdata=getROITypeUnselectedCData(this)

            switch this.Data.ROI
            case labelType.Rectangle
                roiTypeCdata=this.RectUnselectCData;
            case labelType.Line
                roiTypeCdata=this.LineUnselectCData;
            case labelType.PixelLabel
                roiTypeCdata=this.PixelLabelUnselectCData;
            case labelType.ProjectedCuboid
                roiTypeCdata=this.ProjCuboidUnselectCData;
            case labelType.Polygon
                roiTypeCdata=this.PolygonUnselectCData;
            otherwise
                error('unsupported label type');
            end

        end

        function imOut=blendImageWithBG(this,imIn,bgColor)
            assert(isa(imIn,'logical'));
            assert(ismatrix(imIn));


            imIn=double(imIn);
            imOut=zeros([size(imIn),3],'like',imIn);
            tmp=imIn(:,:);
            idx=(tmp==0);
            for i=1:3
                tmp(idx)=bgColor(i);
                imOut(:,:,i)=tmp;
            end
            imOut(imOut==1)=this.IconHighlightedIntensity;
        end

        function imOut=blendAlphaImageWithBG(~,imIn,bgColor,a)
            assert(ismatrix(imIn));
            imIn=im2double(imIn);
            imOut=zeros([size(imIn),3],'like',imIn);
            a=double(a)/255;

            for i=1:3
                imOut(:,:,i)=bgColor(i)*(1-a)+a.*imIn(:,:);
            end
        end

        function computeDownRightArrowIconsCData(this)
            downArrowIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','arrow_down.png');
            downArrowIconData=imread(downArrowIconPath);
            this.DownArrowSelectCData=blendImageWithBG(this,downArrowIconData,this.SelectedBGColor);
            this.DownArrowUnselectCData=blendImageWithBG(this,downArrowIconData,this.UnselectedBGColor);

            rightArrowIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','arrow_right.png');
            rightArrowIconData=imread(rightArrowIconPath);
            this.RightArrowSelectCData=blendImageWithBG(this,rightArrowIconData,this.SelectedBGColor);
            this.RightArrowUnselectCData=blendImageWithBG(this,rightArrowIconData,this.UnselectedBGColor);
        end

        function computeEyeOpenCloseIconsCData(this)
            eyeOpenIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','Show_16.png');
            [eyeOpenIconData,~,alpha]=imread(eyeOpenIconPath);
            eyeOpenIconData=eyeOpenIconData(:,:,1);
            this.EyeOpenSelectCData=blendAlphaImageWithBG(this,eyeOpenIconData,this.SelectedBGColor,alpha);
            this.EyeOpenUnselectCData=blendAlphaImageWithBG(this,eyeOpenIconData,this.UnselectedBGColor,alpha);

            eyeCloseIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons','noShow_16.png');
            [eyeCloseIconData,~,alpha]=imread(eyeCloseIconPath);
            eyeCloseIconData=eyeCloseIconData(:,:,1);
            this.EyeCloseSelectCData=blendAlphaImageWithBG(this,eyeCloseIconData,this.SelectedBGColor,alpha);
            this.EyeCloseUnselectCData=blendAlphaImageWithBG(this,eyeCloseIconData,this.UnselectedBGColor,alpha);
        end

        function computeROITypeIconsCData(this,isALabel,isCuboidSupported)

            if isALabel
                rectROIIconFile=getrectROIIconFile(this,isCuboidSupported);
                lineROIIconPath='ROI_lineBW_Label.png';
                pixelLabelROIIconFile='ROI_pixelLabelBW_Label.png';
                projCuboidROIIconPath='RGB_projCuboidBW_Label.png';
                polygonROIIconPath='ROI_Polygon_Label.png';
            else
                rectROIIconFile='ROI_rectBW_Sublabel.png';
                lineROIIconPath='ROI_lineBW_Sublabel.png';
                pixelLabelROIIconFile='ROI_pixelLabelBW_Sublabel.png';
                projCuboidROIIconPath='RGB_projCuboidBW_Sublabel.png';
                polygonROIIconPath='ROI_Polygon_Sublabel.png';
            end

            rectROIIconPath=getrectROIIconPath(this,rectROIIconFile);
            [rectROIIconData,~,alpha]=imread(rectROIIconPath);
            rectROIIconData=rectROIIconData(:,:,1);
            this.RectSelectCData=blendAlphaImageWithBG(this,rectROIIconData,this.SelectedBGColor,alpha);
            this.RectUnselectCData=blendAlphaImageWithBG(this,rectROIIconData,this.UnselectedBGColor,alpha);

            lineROIIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons',lineROIIconPath);
            lineROIIconData=imread(lineROIIconPath);
            this.LineSelectCData=blendImageWithBG(this,lineROIIconData,this.SelectedBGColor);
            this.LineUnselectCData=blendImageWithBG(this,lineROIIconData,this.UnselectedBGColor);

            pixelLabelROIIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons',pixelLabelROIIconFile);
            [pixelLabelROIIconData,~,alpha]=imread(pixelLabelROIIconPath);
            this.PixelLabelSelectCData=blendAlphaImageWithBG(this,pixelLabelROIIconData,this.SelectedBGColor,alpha);
            this.PixelLabelUnselectCData=blendAlphaImageWithBG(this,pixelLabelROIIconData,this.UnselectedBGColor,alpha);

            projCuboidROIIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons',projCuboidROIIconPath);
            [projCuboidROIIconData,~,alpha]=imread(projCuboidROIIconPath);
            projCuboidROIIconData=projCuboidROIIconData(:,:,1);
            this.ProjCuboidSelectCData=blendAlphaImageWithBG(this,projCuboidROIIconData,this.SelectedBGColor,alpha);
            this.ProjCuboidUnselectCData=blendAlphaImageWithBG(this,projCuboidROIIconData,this.UnselectedBGColor,alpha);

            polygonROIIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons',polygonROIIconPath);
            [polygonROIIconData,~,alpha]=imread(polygonROIIconPath);
            polygonROIIconData=polygonROIIconData(:,:,1);
            this.PolygonSelectCData=blendAlphaImageWithBG(this,polygonROIIconData,this.SelectedBGColor,alpha);
            this.PolygonUnselectCData=blendAlphaImageWithBG(this,polygonROIIconData,this.UnselectedBGColor,alpha);
        end

        function rectROIIconFile=getrectROIIconFile(~,isCuboidSupported)
            if isCuboidSupported
                rectROIIconFile='RGB_rect_cubeBW_Label.png';
            else
                rectROIIconFile='RGB_rect_none_Label.png';
            end
        end

        function rectROIIconPath=getrectROIIconPath(~,rectROIIconFile)
            rectROIIconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons',rectROIIconFile);
        end






        function doButtonDownFcn(this,varargin)

            if this.IsDisabled
                return;
            end

            this.IsClicked=true;
            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index,this.Data);
            notify(this,'ListItemSelected',data);
            this.IsClicked=false;
        end

        function doExpandButtonDownFcn(this,varargin)

            if this.IsDisabled
                return;
            end

            doButtonDownFcn(this,varargin{:});

            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index);

            if this.IsExpanded
                notify(this,'ListItemShrinked',data);
            else
                notify(this,'ListItemExpanded',data);
            end
        end

        function doROIVisibilityButtonDownFcn(this,varargin)

            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index,this.Data);
            if~this.IsROIChecked
                this.EyeOpenCloseImgHnd.CData=this.EyeCloseSelectCData;
                data.Data.ROIVisibility=false;
            else
                this.EyeOpenCloseImgHnd.CData=this.EyeOpenSelectCData;
                data.Data.ROIVisibility=true;
            end

            notify(this,'ListItemROIVisibility',data);
            this.IsROIChecked=~this.IsROIChecked;
        end

        function select(this)
            this.Panel.BackgroundColor=this.SelectedBGColor;
            if this.IsExpanded
                this.RightDownArrowImgHnd.CData=this.DownArrowSelectCData;
            else
                this.RightDownArrowImgHnd.CData=this.RightArrowSelectCData;
            end

            this.ROITypeImgHnd.CData=this.getROITypeSelectedCData();

            this.ROILabelText.BackgroundColor=this.SelectedBGColor;
            this.ROILabelText.FontWeight='bold';
            this.EyeOpenCloseImgHnd.CData=this.EyeOpenSelectCData;

            this.IsSelected=true;
            this.DescriptionTextBox.BackgroundColor=this.SelectedBGColor;
            this.DescriptionEditBox.BackgroundColor=this.SelectedBGColor;
            this.AttributeTextBox.BackgroundColor=this.SelectedBGColor;
            this.AttributeEditBox.BackgroundColor=this.SelectedBGColor;
            if this.IsROIChecked
                this.Data.ROIVisibility=true;
                data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index,this.Data);
                notify(this,'ListItemROIVisibility',data);
                this.IsROIChecked=false;
            end
        end

        function unselect(this)
            this.Panel.BackgroundColor=this.UnselectedBGColor;
            if this.IsExpanded
                this.RightDownArrowImgHnd.CData=this.DownArrowUnselectCData;
            else
                this.RightDownArrowImgHnd.CData=this.RightArrowUnselectCData;
            end

            this.ROITypeImgHnd.CData=this.getROITypeUnselectedCData();

            this.ROILabelText.BackgroundColor=this.UnselectedBGColor;
            this.ROILabelText.FontWeight='normal';


            if(~this.IsDisabled)
                this.ROILabelText.Enable='inactive';
            end

            this.IsSelected=false;
            this.DescriptionTextBox.BackgroundColor=this.UnselectedBGColor;
            this.DescriptionEditBox.BackgroundColor=this.UnselectedBGColor;
            this.AttributeTextBox.BackgroundColor=this.UnselectedBGColor;
            this.AttributeEditBox.BackgroundColor=this.UnselectedBGColor;
        end

        function disable(this)
            this.IsDisabled=true;

            this.ROILabelText.Enable='off';
            set(this.RightDownArrowImgHnd,'ButtonDownFcn','');

            freeze(this);
        end

        function enable(this)
            this.IsDisabled=false;
            this.ROILabelText.Enable='inactive';
            set(this.RightDownArrowImgHnd,'ButtonDownFcn',@this.doExpandButtonDownFcn);
            unfreeze(this);
        end

        function makeVisible(this)
            this.Panel.Visible='on';
            this.Visible=true;
        end

        function makeInvisible(this)
            this.Panel.Visible='off';
            this.Visible=false;
        end

        function freeze(this)
            this.Panel.UIContextMenu=gobjects(0);
            this.ROILabelText.UIContextMenu=gobjects(0);
            this.DescriptionTextBox.UIContextMenu=gobjects(0);
            this.DescriptionEditBox.UIContextMenu=gobjects(0);
            this.AttributeTextBox.UIContextMenu=gobjects(0);
            this.AttributeEditBox.UIContextMenu=gobjects(0);
        end

        function unfreeze(this)
            this.Panel.UIContextMenu=this.ItemContextMenu;
            this.ROILabelText.UIContextMenu=this.ItemContextMenu;
            this.DescriptionTextBox.UIContextMenu=this.ItemContextMenu;
            this.DescriptionEditBox.UIContextMenu=this.ItemContextMenu;
            this.AttributeTextBox.UIContextMenu=this.ItemContextMenu;
            this.AttributeEditBox.UIContextMenu=this.ItemContextMenu;
        end

        function expand(this)
            if this.IsExpanded
                return;
            end
            if this.HideAttribute
                thisShift=this.ShiftP;
            else
                thisShift=this.Shift;
            end
            this.RightDownArrowImgHnd.CData=this.DownArrowSelectCData;

            this.Panel.Position(4)=this.Panel.Position(4)+thisShift;
            this.RightDownArrowPanel.Position(2)=this.RightDownArrowPanel.Position(2)+thisShift;
            this.ROILabelText.Position(2)=this.ROILabelText.Position(2)+thisShift;
            this.EyeOpenClosePanel.Position(2)=this.EyeOpenClosePanel.Position(2)+thisShift;
            this.ROIColorPanel.Position(2)=this.ROIColorPanel.Position(2)+thisShift;
            this.ROITypePanel.Position(2)=this.ROITypePanel.Position(2)+thisShift;

            this.DescriptionTextBox.Visible='on';
            this.DescriptionEditBox.Visible='on';
            if this.HideAttribute
                this.AttributeTextBox.Visible='off';
                this.AttributeEditBox.Visible='off';
            else
                this.AttributeTextBox.Visible='on';
                this.AttributeEditBox.Visible='on';
            end
            this.IsExpanded=~this.IsExpanded;
        end

        function shrink(this)
            if~this.IsExpanded
                return;
            end
            if this.HideAttribute
                thisShift=this.ShiftP;
            else
                thisShift=this.Shift;
            end

            this.RightDownArrowImgHnd.CData=this.RightArrowSelectCData;

            this.Panel.Position(4)=this.Panel.Position(4)-thisShift;
            this.RightDownArrowPanel.Position(2)=this.RightDownArrowPanel.Position(2)-thisShift;
            this.ROILabelText.Position(2)=this.ROILabelText.Position(2)-thisShift;
            this.EyeOpenClosePanel.Position(2)=this.EyeOpenClosePanel.Position(2)-thisShift;
            this.ROIColorPanel.Position(2)=this.ROIColorPanel.Position(2)-thisShift;
            this.ROITypePanel.Position(2)=this.ROITypePanel.Position(2)-thisShift;

            set(this.DescriptionTextBox,'Visible','off');
            set(this.DescriptionEditBox,'Visible','off');
            set(this.AttributeTextBox,'Visible','off');
            set(this.AttributeEditBox,'Visible','off');
            this.IsExpanded=~this.IsExpanded;
        end

        function str=attrib2DisplayString(~,attrib)
            if isempty(attrib)
                str='';
            else
                str=attrib{1};
                for i=2:length(attrib)
                    str=sprintf([str,'\n',attrib{i}]);
                end
            end
        end

        function hasMatch=compareDataElement(this,varargin)
            labelName=varargin{1};
            sublabelName=varargin{2};

            if~isempty(sublabelName)
                hasMatch=isprop(this.Data,'LabelName')&&...
                strcmpi(this.Data.LabelName,labelName)&&...
                isprop(this.Data,'Sublabel')&&...
                strcmpi(this.Data.Sublabel,sublabelName);
            else
                hasMatch=isprop(this.Data,'Label')&&...
                strcmpi(this.Data.Label,labelName);
            end
        end

        function recreateContextMenu(this,cMenu)
            if numel(cMenu.Children)==4
                appendAsEditAttribParentContextMenu(this);
                appendAsDeleteAttribParentContextMenu(this);

                for i=1:4
                    if~isempty(cMenu.Children(i).Children)
                        for j=1:numel(cMenu.Children(i).Children)
                            attributeName=cMenu.Children(i).Children(j).Text;
                            appendAsEditAttribChildContextMenu(this,attributeName);
                            appendAsDeleteAttribChildContextMenu(this,attributeName);
                        end
                        break;
                    end
                end
            end
        end

        function resetAttribMenuHandles(this)
            this.EditAttributeChildMenuHandles=[];
            this.DeleteAttributeChildMenuHandles=[];
            this.EditAttributeParentMenuHandle=[];
            this.DeleteAttributeParentMenuHandle=[];
        end

        function resetChildContextMenu(this)
            createDefaultContextMenu(this);
            resetAttribMenuHandles(this);
        end




        function modifyDescription(this,roiLabel)
            this.Description=roiLabel.Description;
            this.DescriptionEditBox.String=this.Description;
            this.Data.Description=this.Description;
        end


        function modifyName(this,newName,changeDisplay)




            if changeDisplay


                maxTextLenInPixel=this.ROIColorPanel.Position(1)-20-this.ROITextAndColorXSpacing-this.TextStartX;
                shortLabel=vision.internal.labeler.tool.shortenLabel(newName,maxTextLenInPixel);

                this.ROILabelText.String=shortLabel;
                this.ROILabelText.TooltipString=newName;

                if isprop(this.Data,'Label')
                    this.Data.Label=newName;
                else
                    this.Data.Sublabel=newName;
                end
            else
                this.Data.LabelName=newName;
            end
        end


        function modifyColor(this,newLabelColor)
            this.Data.Color=newLabelColor;
            this.ROIColorPanel.BackgroundColor=newLabelColor;
        end


        function modifyAttributeName(this,data,newName)


            oldAttribName=data.Name;
            idx=find(contains(this.Data.AttributeNames,oldAttribName));
            this.Data.AttributeNames(idx)={newName};%#ok<FNDSB> % squeezing the array
            this.AttributeEditBox.String=attrib2DisplayString(this,this.Data.AttributeNames);



            h=this.EditAttributeChildMenuHandles.(oldAttribName);
            h.Label=newName;
            h.Callback{2}=newName;
            this.EditAttributeChildMenuHandles.(newName)=h;
            this.EditAttributeChildMenuHandles.(oldAttribName)=[];



            h=this.DeleteAttributeChildMenuHandles.(oldAttribName);
            h.Label=newName;
            h.Callback{2}=newName;
            this.DeleteAttributeChildMenuHandles.(newName)=h;
            this.DeleteAttributeChildMenuHandles.(oldAttribName)=[];
        end


        function modifyPosition(this,position)
            this.Position=position;
        end


        function modifyIndex(this,newIndex)
            this.Index=newIndex;
        end


        function modifyData(this,newData)
            this.Data.Group=newData.Group;
        end

        function appendAttribute(this,data)
            if ischar(data)
                attributeName=data;
            else
                attributeName=data.Name;
            end

            this.Data.AttributeNames{end+1}=attributeName;

            this.AttributeEditBox.String=attrib2DisplayString(this,this.Data.AttributeNames);

            if isempty(this.EditAttributeParentMenuHandle)


                appendAsEditAttribParentContextMenu(this);
            end

            if isempty(this.DeleteAttributeParentMenuHandle)
                appendAsDeleteAttribParentContextMenu(this);
            end

            appendAsEditAttribChildContextMenu(this,attributeName);

            appendAsDeleteAttribChildContextMenu(this,attributeName);
        end

        function deleteAttribute(this,attributeName)

            removeAndString(this,attributeName);

            if isfield(this.DeleteAttributeChildMenuHandles,attributeName)&&...
                ~isempty(this.DeleteAttributeChildMenuHandles.(attributeName))
                delete(this.DeleteAttributeChildMenuHandles.(attributeName));
                this.DeleteAttributeChildMenuHandles.(attributeName)=[];
            end

            if isfield(this.EditAttributeChildMenuHandles,attributeName)&&...
                ~isempty(this.EditAttributeChildMenuHandles.(attributeName))
                delete(this.EditAttributeChildMenuHandles.(attributeName));
                this.EditAttributeChildMenuHandles.(attributeName)=[];
            end

            if hasNoAttributeToDelete(this)&&...
                ~isempty(this.DeleteAttributeParentMenuHandle)
                delete(this.DeleteAttributeParentMenuHandle);
                this.DeleteAttributeParentMenuHandle=[];
            end

            if hasNoAttributeToEdit(this)&&...
                ~isempty(this.EditAttributeParentMenuHandle)
                delete(this.EditAttributeParentMenuHandle);
                this.EditAttributeParentMenuHandle=[];
            end
        end

        function appendAsEditAttribParentContextMenu(this)

            h=uimenu(this.ItemContextMenu,...
            'Label',vision.getMessage('vision:labeler:ContextMenuEditAttribute'));
            this.EditAttributeParentMenuHandle=h;
        end
        function appendAsDeleteAttribParentContextMenu(this)

            h=uimenu(this.ItemContextMenu,...
            'Label',vision.getMessage('vision:labeler:ContextMenuDeleteAttribute'));
            this.DeleteAttributeParentMenuHandle=h;
        end

        function appendAsEditAttribChildContextMenu(this,attributeName)

            h=uimenu(this.EditAttributeParentMenuHandle,...
            'Label',attributeName,...
            'Callback',{@this.OnCallbackEditAttribute,attributeName});
            this.EditAttributeChildMenuHandles.(attributeName)=h;
        end


        function appendAsDeleteAttribChildContextMenu(this,attributeName)

            h=uimenu(this.DeleteAttributeParentMenuHandle,...
            'Label',attributeName,...
            'Callback',{@this.OnCallbackDeleteAttribute,attributeName});
            this.DeleteAttributeChildMenuHandles.(attributeName)=h;
        end


        function removeAndString(this,attributeName)

            idx=find(contains(this.Data.AttributeNames,attributeName));
            this.Data.AttributeNames(idx)=[];%#ok<FNDSB> % squeezing the array


            this.AttributeEditBox.String=attrib2DisplayString(this,this.Data.AttributeNames);
        end



        function OnCallbackEditAttribute(this,varargin)
            attributeName=varargin{3};
            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index,attributeName);
            notify(this,'ListItemBeingEdited',data);
        end


        function OnCallbackDeleteAttribute(this,varargin)
            attributeName=varargin{3};
            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index,this.Data,attributeName);
            notify(this,'ListItemDeleted',data);
        end


        function OnCallbackEditItem(this,varargin)
            data=vision.internal.labeler.tool.ItemModifiedEvent(this.Index,this.Data);
            notify(this,'ListItemModified',data);
        end


        function OnCallbackDeleteItem(this,varargin)
            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index,this.Data);
            notify(this,'ListItemDeleted',data);
        end


        function adjustWidth(this,parentWidth)
            this.Panel.Position(3)=max(this.MinWidth,parentWidth);
            this.DescriptionEditBox.Position(3)=this.Panel.Position(3)-16;
            this.AttributeEditBox.Position(3)=this.Panel.Position(3)-16;
        end


        function delete(this)
            delete(this.Panel);
            delete(this.ItemContextMenu);
        end


        function TF=isImageLabeler(~,parent)
            h=get(parent,'parent');
            hp=get(h,'parent');
            TF=strcmp(hp.UserData,'ImageLabeler');
        end


        function tf=hasNoAttributeToDelete(this)
            if isempty(this.DeleteAttributeChildMenuHandles)
                tf=true;
            else
                tf=all(structfun(@isempty,this.DeleteAttributeChildMenuHandles));
            end
        end


        function tf=hasNoAttributeToEdit(this)
            if isempty(this.EditAttributeChildMenuHandles)
                tf=true;
            else
                tf=all(structfun(@isempty,this.EditAttributeChildMenuHandles));
            end
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end