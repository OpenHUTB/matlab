


classdef ROILabelSetDisplay<lidar.internal.labeler.tool.LabelSetDisplay

    properties(Constant)


        AddLabelPanelHeight=4;
        AddLabelButtonHeight=0.8*3;
        ButtonOffset=1.5
        ButtonTextHeight=1.5
        ButtonTextOffset=0
    end


    properties(Access=private)

AddSublabelButton
AddAttributeButton
AddSublabelText
AddAttributeText
    end


    events

ROIPanelItemSelected


ROIPanelItemModified


ROIPanelItemRemoved

ROIPanelItemBeingEdited

ROIPanelItemVisibility
    end




    methods(Access=public)

        function this=ROILabelSetDisplay(hFig,toolName)

            nameDisplayedInTab=vision.getMessage(...
            'vision:labeler:ROILabelSetDisplayName');
            this@lidar.internal.labeler.tool.LabelSetDisplay(hFig,toolName,nameDisplayedInTab);

            [addLabelPanelPos,labelSetPanelPos,buttonPos,helperPos]=uicontrolPositions(this);

            roiDefCreationIcons=load(fullfile(toolboxdir('vision'),...
            'vision','+vision','+internal','+labeler','+tool','+icons',...
            'roiDefCreationIcons.mat'));
            newLabelIcon=roiDefCreationIcons.newLabelIcon;
            newSublabelIcon=roiDefCreationIcons.newSublabelIcon;
            newAttributeIcon=roiDefCreationIcons.newAttributeIcon;

            if~isdeployed()


                if~useAppContainer
                    this.AddLabelPanel=uipanel(this.Fig,...
                    'Units','char',...
                    'BorderType','line',...
                    'HighlightColor',[0.65,0.65,0.65],...
                    'Position',addLabelPanelPos,...
                    'Tag','AddLabelPanel');
                else

                    this.AddLabelPanel=uipanel(this.Fig,...
                    'BorderType','line',...
                    'Units','normalized',...
                    'Position',addLabelPanelPos,...
                    'Tag','AddLabelPanel',...
                    'AutoResizeChildren','off');
                end


                [textPos,buttonPos]=labelButton(this,buttonPos,newLabelIcon);


                [textPos,sublabelTextWidth]=subLabelButton(this,textPos,buttonPos,newSublabelIcon);


                attributeButton(this,textPos,buttonPos,sublabelTextWidth,newAttributeIcon);
            end





            this.LabelSetPanel=lidar.internal.labeler.tool.ROILabelSetPanel(this.Fig,labelSetPanelPos);



            addlistener(this.LabelSetPanel,'ItemSelected',@this.doROIPanelItemSelected);
            addlistener(this.LabelSetPanel,'ItemModified',@this.doROIPanelItemModified);
            addlistener(this.LabelSetPanel,'ItemRemoved',@this.doPanelItemDeleted);
            addlistener(this.LabelSetPanel,'ItemShrinked',@this.doPanelItemShrinked);
            addlistener(this.LabelSetPanel,'ItemExpanded',@this.doPanelItemExpanded);
            addlistener(this.LabelSetPanel,'ItemBeingEdited',@this.doROIPanelItemBeingEdited);
            addlistener(this.LabelSetPanel,'ItemROIVisibility',@this.doROIPanelItemVisibility);

            this.Fig.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;


            if~isdeployed()
                if strcmpi(this.ToolName,'groundTruthLabeler')
                    txt=vision.getMessage('vision:labeler:ROIMultiSignalHelperText');
                elseif strcmpi(this.ToolName,'lidarLabeler')
                    txt=vision.getMessage('lidar:labeler:ROILidarLabelerHelperText');
                else
                    txt=vision.getMessage('vision:labeler:ROIHelperText');
                end
            else
                txt=vision.getMessage('vision:labeler:ROIHelperTextDeployment');
            end
            this.HelperText=showHelperText(this,txt,helperPos);
            this.LabelSetPanel.ItemFactory=lidar.internal.labeler.tool.ROILabelItemFactory();
        end


        function[textPos,buttonPos]=labelButton(this,buttonPos,newLabelIcon)
            buttonPos(2)=this.ButtonOffset;
            this.AddLabelButton=uicontrol('style','pushbutton','Parent',this.AddLabelPanel,...
            'Units','char',...
            'CData',newLabelIcon,...
            'ForegroundColor',this.AddButtonTextColor,...
            'Position',buttonPos,...
            'Tag','AddROILabelButton');

            tip=vision.getMessage('vision:labeler:AddNewROILabelToolTip');
            txt=vision.getMessage('vision:labeler:NewLabelButtonTitle');
            labelTextWidth=numel(txt)+sum(isspace(txt))+5;

            this.AddLabelButton.TooltipString=tip;


            textPos=[1,this.ButtonTextOffset,labelTextWidth,this.ButtonTextHeight];
            this.AddLabelText=uicontrol('style','text',...
            'Parent',this.AddLabelPanel,...
            'Units','char',...
            'HorizontalAlignment','left',...
            'String',txt,...
            'Position',textPos);
        end

        function[textPos,sublabelTextWidth]=subLabelButton(this,~,~,~,~)

            txt=vision.getMessage('vision:labeler:NewSublabelButtonTitle');
            sublabelTextWidth=numel(txt)+sum(isspace(txt))+7;
            textPos=[sublabelTextWidth+1,this.ButtonTextOffset,sublabelTextWidth,this.ButtonTextHeight];
        end


        function[myButtonPos,textPos,txt]=attributeButton(this,textPos,buttonPos,...
            sublabelTextWidth,newAttributeIcon)
            [myButtonPos,textPos,txt]=attributeButtonPos(this,textPos,buttonPos,sublabelTextWidth);

            this.AddAttributeButton=uicontrol('style','pushbutton','Parent',this.AddLabelPanel,...
            'Units','char',...
            'CData',newAttributeIcon,...
            'ForegroundColor',this.AddButtonTextColor,...
            'Enable','off',...
            'Position',myButtonPos,...
            'TooltipString',vision.getMessage('vision:labeler:AddNewAttributeToolTip'),...
            'Tag','AddROIAttributeButton');

            this.AddAttributeText=uicontrol('style','text',...
            'Parent',this.AddLabelPanel,...
            'Units','char',...
            'HorizontalAlignment','left',...
            'Enable','off',...
            'String',txt,...
            'Position',textPos);
        end

        function[myButtonPos,textPos,txt]=attributeButtonPos(this,~,buttonPos,sublabelTextWidth)

            myButtonPos=buttonPos;
            myButtonPos(1)=sublabelTextWidth;
            myButtonPos(2)=this.ButtonOffset;
            txt=vision.getMessage('vision:labeler:NewAttributeButtonTitle');
            textPos=[sublabelTextWidth+1,this.ButtonTextOffset,sublabelTextWidth,this.ButtonTextHeight];
        end
    end




    methods(Access=public)




        function configure(this,selectionCallback,labelAdditionCallBack,...
            sublabelAdditionCallBack,attributeAdditionCallBack,...
            modificationCallback,deletionCallback,moveCallback,beingEditedCallback,...
            roiVisibilityCallback,varargin)


            addlistener(this,'ROIPanelItemSelected',selectionCallback);

            addlistener(this,'ROIPanelItemModified',modificationCallback);

            listenerObj=addlistener(this,'ROIPanelItemRemoved',deletionCallback);



            listenerObj.Recursive=true;


            addlistener(this,'PanelItemMoved',moveCallback);

            addlistener(this,'ROIPanelItemBeingEdited',beingEditedCallback);

            addlistener(this,'ROIPanelItemVisibility',roiVisibilityCallback);

            if~isdeployed()

                this.AddLabelButton.Callback=labelAdditionCallBack;
                this.AddLabelText.Callback=labelAdditionCallBack;

                this.AddSublabelButton.Callback=sublabelAdditionCallBack;
                this.AddSublabelText.Callback=sublabelAdditionCallBack;

                this.AddAttributeButton.Callback=attributeAdditionCallBack;
                this.AddAttributeText.Callback=attributeAdditionCallBack;
            end

            if nargin>10


                keyPressCallback=varargin{1};
                this.Fig.WindowKeyPressFcn=keyPressCallback;
            end
        end
    end




    methods(Access=public)

        function setSublabelCreateButtonStatus(this,s)
            this.AddSublabelButton.Enable=s;
            this.AddSublabelText.Enable=s;
        end


        function setAttributeCreateButtonStatus(this,s)
            this.AddAttributeButton.Enable=s;
            this.AddAttributeText.Enable=s;
        end


        function enableSublabelDefCreateButton(this)
            setSublabelCreateButtonStatus(this,'on');
        end


        function disableSublabelDefCreateButton(this)
            setSublabelCreateButtonStatus(this,'off');
        end


        function enableAttributeDefCreateButton(this)
            setAttributeCreateButtonStatus(this,'on');
        end


        function disableAttributeDefCreateButton(this)
            setAttributeCreateButtonStatus(this,'off');
        end


        function deleteAllSublabels(this)

        end
    end




    methods(Access=public)


        function appendItemAttribute(this,data,itemIdx)
            this.LabelSetPanel.appendItemAttribute(data,itemIdx);
        end


        function deleteItemAttribute(this,idx,name)
            this.LabelSetPanel.deleteItemAttribute(idx,name);
        end


        function modifyItemMenuLabel(this,idx,isLabel)
            this.LabelSetPanel.modifyItemMenuLabel(idx,isLabel);
        end


        function modifyItemAttributeName(this,idx,data,newName)
            this.LabelSetPanel.modifyItemAttributeName(idx,data,newName);
        end


        function modifyItemName(this,idx,newName,changeDisplay)
            this.LabelSetPanel.modifyItemName(idx,newName,changeDisplay);
        end


        function modifyItemColor(this,newLabelColor)
            idx=this.LabelSetPanel.CurrentSelection;
            this.LabelSetPanel.modifyItemColor(idx,newLabelColor);
        end


        function unselectToBeDisabledItems(this,idx)
            this.LabelSetPanel.unselectToBeDisabledItems(idx);
        end
    end




    methods(Access=public)

        function freeze(this)
            if~isdeployed()
                this.AddLabelButton.Enable='off';
                this.AddLabelText.Enable='off';
                if~isempty(this.AddSublabelButton)
                    this.AddSublabelButton.Enable='off';
                    this.AddSublabelText.Enable='off';
                end
                if~isempty(this.AddAttributeButton)
                    this.AddAttributeButton.Enable='off';
                    this.AddAttributeText.Enable='off';
                end
            end

            this.LabelSetPanel.freezeAllItems();
        end


        function unfreeze(this)
            if~isdeployed()

                this.AddLabelButton.Enable='on';
                this.AddLabelText.Enable='on';
                if~isempty(this.AddSublabelButton)
                    this.AddSublabelButton.Enable='on';
                    this.AddSublabelText.Enable='on';
                end
                if~isempty(this.AddAttributeButton)
                    this.AddAttributeButton.Enable='on';
                    this.AddAttributeText.Enable='on';
                end
            end
            this.LabelSetPanel.unfreezeAllItems();
        end
    end




    methods

        function itemID=getItemID(this,labelName,sublabelName)
            itemID=this.LabelSetPanel.getItemID(labelName,sublabelName);
        end


        function labeltext=getAddLabelText(this)
            labeltext=this.AddLabelText;
        end


        function grabFocus(this)
            figure(this.Fig);
        end


        function flag=isPanelVisible(this)
            flag=strcmpi(this.Fig.Visible,'on');
        end
    end




    methods





        function[addLabelPanel,labelSetPanel,buttonPos,helperText]=uicontrolPositions(this)
            figPos=hgconvertunits(this.Fig,this.Fig.Position,this.Fig.Units,'char',this.Fig);

            if isdeployed()
                addLabelPanelHeight=0;
            else
                addLabelPanelHeight=this.AddLabelPanelHeight;
            end

            addLabelPanel=[0,figPos(4)-addLabelPanelHeight,figPos(3),addLabelPanelHeight];

            addLabelPanelNormalized=hgconvertunits(this.Fig,addLabelPanel,'char','normalized',this.Fig);
            helperText=[0.05,addLabelPanelNormalized(2)-0.54,0.9,0.5];



            h=max(0,figPos(4)-addLabelPanel(4));
            labelSetPanel=hgconvertunits(this.Fig,[0,0,figPos(3),h],'char','normalized',this.Fig);


            buttnPixPos=[0,0,this.AddLabelButtonSizeInPixels];
            buttonPos=hgconvertunits(this.Fig,buttnPixPos,'pixels','char',this.Fig);
            if useAppContainer
                addLabelPanel=addLabelPanelNormalized;
            end
        end

        function remainingUIUpdates(this)


        end
    end




    methods

        function repositionROILabelInRow(this)
            if this.NumItems>0
                [roiColorPanelStartX,roiTypePanelStartX]=getROIColorNTypePanelStartX(this);
                for i=1:this.NumItems
                    if~isaGroupItem(this,i)
                        thisItem=this.LabelSetPanel.Items{i};
                        thisItem.ROIColorPanel.Position(1)=roiColorPanelStartX;
                        thisItem.ROITypePanel.Position(1)=roiTypePanelStartX;

                        maxTextLenInPixel=roiColorPanelStartX-thisItem.ROITextAndColorXSpacing-thisItem.TextStartX;
                        shortLabel=vision.internal.labeler.tool.shortenLabel(thisItem.ROILabelText.TooltipString,maxTextLenInPixel);
                        thisItem.ROILabelText.String=shortLabel;
                    end
                end
            end
        end


        function doPanelPositionUpdate(this)
            [pos1,pos2,buttonPos,pos3]=uicontrolPositions(this);
            if~isdeployed()
                this.AddLabelPanel.Position=pos1;
                buttonPos(2)=this.ButtonOffset;
                this.AddLabelButton.Position=buttonPos;
            end
            this.LabelSetPanel.Position=pos2;
            this.HelperText.Position=pos3;
            repositionROILabelInRow(this);
        end


        function[roiColorPanelStartX,roiTypePanelStartX]=getROIColorNTypePanelStartX(this)
            assert(this.NumItems>0);
            w=this.Fig.Position(3);

            if isaGroupItem(this,1)
                itemObj=this.LabelSetPanel.Items{2};
            else
                itemObj=this.LabelSetPanel.Items{1};
            end

            if w>itemObj.MinWidth
                if w>itemObj.MaxWidthReqForROILabelRow
                    roiColorPanelStartX=itemObj.MaxROIColorPanelStartX;
                else



                    roiColorPanelStartX=w-itemObj.ROILabelRowRightClearance...
                    -itemObj.ROITypePanel.Position(3)...
                    -itemObj.ROIColorAndTypeXSpacing...
                    -itemObj.ROIColorPanel.Position(3);
                end
            else
                roiColorPanelStartX=itemObj.MinROIColorPanelStartX;
            end

            roiTypePanelStartX=roiColorPanelStartX+...
            itemObj.ROIColorPanel.Position(3)+...
            itemObj.ROIColorAndTypeXSpacing;
        end


        function doROIPanelItemSelected(this,~,data)

            data.Data=this.LabelSetPanel.Items{data.Index}.Data;

            doPanelItemSelected(this,data);


            notify(this,'ROIPanelItemSelected',data);
        end


        function doROIPanelItemModified(this,~,data)

            notify(this,'ROIPanelItemModified',data);
        end


        function doPanelItemDeleted(this,~,data)

            notify(this,'ROIPanelItemRemoved',data);
        end


        function doROIPanelItemBeingEdited(this,~,data)

            notify(this,'ROIPanelItemBeingEdited',data);
        end


        function doROIPanelItemVisibility(this,~,data)

            notify(this,'ROIPanelItemVisibility',data);
        end

    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
