


classdef GroupItem<vision.internal.labeler.tool.ListItem


    properties(Constant)
        MinWidth=185;
        SelectedBGColor=[0.9882,0.9882,0.8627];
        UnselectedBGColor=[0.94,0.94,0.94];
        ArrowIconW=10;
        ArrowAndTextSpaceX=10;
        IconHighlightedIntensity=0.4;
    end

    properties
Panel
RightDownArrowPanel
GroupLabelText

IsDisabled
IsExpanded
IsSelected

Index
Data

        ArrowIconStartX=9;
TextStartX
        MaxTextWidth=200;


RightDownArrowImgHnd
RightArrowSelectCData
RightArrowUnselectCData
DownArrowSelectCData
DownArrowUnselectCData

ItemContextMenu



        Visible=true




        IsClicked=false;
    end

    properties(Dependent=true,SetAccess=private)
Name
    end

    methods
        function this=GroupItem(parent,idx,data)

            setConsDependentProps(this);
            computeDownRightArrowIconsCData(this);

            this.Index=idx;
            this.IsDisabled=false;
            this.IsExpanded=true;
            this.Data=data;

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


            ArrowIconH=this.ArrowIconW;
            this.RightDownArrowPanel=uipanel('Parent',this.Panel,...
            'Visible','on',...
            'Units','pixels',...
            'BackgroundColor',parent.BackgroundColor,...
            'BorderType','none',...
            'Position',[this.ArrowIconStartX,9,this.ArrowIconW,ArrowIconH]);

            showArrowIconAndSaveHandle(this);


            set(this.RightDownArrowImgHnd,'ButtonDownFcn',@this.doExpandButtonDownFcn);


            textPos=[this.TextStartX,0,this.MaxTextWidth,20];
            fullLabel=this.Data.Group;
            shortLabel=this.Data.Group;
            this.GroupLabelText=uicontrol('Style','text',...
            'Parent',this.Panel,...
            'TooltipString',fullLabel,...
            'String',shortLabel,...
            'Position',textPos,...
            'FontName','Arial',...
            'FontSize',10,...
            'HorizontalAlignment','left',...
            'Enable','inactive',...
            'ButtonDownFcn',@this.doButtonDownFcn);


            panelFigure=ancestor(this.Panel,'Figure');
            this.ItemContextMenu=uicontextmenu(panelFigure);
            uimenu(this.ItemContextMenu,'Label',...
            vision.getMessage('vision:labeler:ContextMenuRenameGroup'),...
            'Callback',@this.OnCallbackRenameItem);
            uimenu(this.ItemContextMenu,'Label',...
            vision.getMessage('vision:labeler:ContextMenuDelete'),...
            'Callback',@this.OnCallbackDeleteItem);
            this.Panel.UIContextMenu=this.ItemContextMenu;
            this.GroupLabelText.UIContextMenu=this.ItemContextMenu;

        end

        function name=get.Name(this)
            name=this.Data.Group;
        end



        function containerW=getContainerWidth(~,parent)
            fig=ancestor(parent,'Figure');
            containerW=fig.Position(3);
        end

        function setConsDependentProps(this)
            this.TextStartX=this.ArrowIconStartX+this.ArrowIconW+...
            this.ArrowAndTextSpaceX;
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

        function showArrowIconAndSaveHandle(this)
            hax=axes('Units','normal','Position',[0,0,1,1],'Parent',this.RightDownArrowPanel);
            this.RightDownArrowImgHnd=imshow(this.DownArrowUnselectCData,[],'InitialMagnification','fit','Parent',hax);
        end




        function select(this)
            this.Panel.BackgroundColor=this.SelectedBGColor;
            if this.IsExpanded
                this.RightDownArrowImgHnd.CData=this.DownArrowSelectCData;
            else
                this.RightDownArrowImgHnd.CData=this.RightArrowSelectCData;
            end

            this.GroupLabelText.BackgroundColor=this.SelectedBGColor;
            this.GroupLabelText.FontWeight='bold';
            this.IsSelected=true;
        end

        function unselect(this)
            this.Panel.BackgroundColor=this.UnselectedBGColor;
            if this.IsExpanded
                this.RightDownArrowImgHnd.CData=this.DownArrowUnselectCData;
            else
                this.RightDownArrowImgHnd.CData=this.RightArrowUnselectCData;
            end

            this.GroupLabelText.BackgroundColor=this.UnselectedBGColor;
            this.GroupLabelText.FontWeight='normal';
            this.IsSelected=false;
        end




        function modifyData(this,data)
            this.Data.Group=data;
            this.GroupLabelText.String=data;
        end

        function modifyPosition(this,position)
            this.Position=position;
        end

        function modifyIndex(this,newIndex)
            this.Index=newIndex;
        end




        function expand(this)
            if this.IsExpanded
                return;
            end
            this.RightDownArrowImgHnd.CData=this.DownArrowSelectCData;
            this.IsExpanded=~this.IsExpanded;
        end

        function shrink(this)
            if~this.IsExpanded
                return;
            end
            this.RightDownArrowImgHnd.CData=this.RightArrowSelectCData;
            this.IsExpanded=~this.IsExpanded;
        end

        function freeze(this)
            this.Panel.UIContextMenu=gobjects(0);
            this.GroupLabelText.UIContextMenu=gobjects(0);
        end

        function unfreeze(this)
            this.Panel.UIContextMenu=this.ItemContextMenu;
            this.GroupLabelText.UIContextMenu=this.ItemContextMenu;
        end





        function disable(this)
            this.IsDisabled=true;

            this.GroupLabelText.Enable='off';
            set(this.RightDownArrowImgHnd,'ButtonDownFcn','');

            freeze(this);
        end

        function enable(this)
            this.IsDisabled=false;
            this.GroupLabelText.Enable='inactive';
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





        function doButtonDownFcn(this,varargin)

            if this.IsDisabled
                return;
            end

            this.IsClicked=true;
            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index);
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

        function OnCallbackDeleteItem(this,varargin)
            data=vision.internal.labeler.tool.ItemSelectedEvent(this.Index,this.Data);
            notify(this,'ListItemDeleted',data);
        end


        function OnCallbackRenameItem(this,varargin)
            data=vision.internal.labeler.tool.ItemModifiedEvent(this.Index,this.Data);
            notify(this,'ListItemModified',data);
        end





        function hasMatch=compareDataElement(~,varargin)

            hasMatch=false;
        end


        function delete(this)
            delete(this.Panel);
            delete(this.ItemContextMenu);
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end