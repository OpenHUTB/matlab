
classdef FrameLabelSetDisplay<vision.internal.labeler.tool.LabelSetDisplay
    properties(Constant)


        AddLabelPanelHeight=3;
        AddLabelButtonHeight=0.8*3;
        FrameLabelOptionsPanelHeight=6;
        RadioButtonWidth=18;
        ActionButtonWidth=18;
    end

    properties

FrameLabelOptionsBGPanel
FrameLabelOptionsPanel
FrameLabelOptionGroup
FrameRadioButton
FrameIntervalRadioButton
AddFrameLabelButton
RemoveFrameLabelButton
    end

    events


FrameLabeled

FrameUnlabeled


FrameLabelSelected


FrameLabelModified


FrameLabelRemoved
    end




    methods(Access=public)

        function this=FrameLabelSetDisplay(hFig,toolName)
            nameDisplayedInTab=vision.getMessage(...
            'vision:labeler:FrameLabelSetDisplayName');

            this=this@vision.internal.labeler.tool.LabelSetDisplay(hFig,toolName,nameDisplayedInTab);

            [addLabelPanelPos,labelSetPanelPos,buttonPos,...
            frameOptionsPanelPos,frameOptionsBGPanelPos,helperPos]=uicontrolPositions(this);

            if~isdeployed()


                if~useAppContainer()
                    this.AddLabelPanel=uipanel(this.Fig,...
                    'Units','char',...
                    'BorderType','line',...
                    'HighlightColor',[0.65,0.65,0.65],...
                    'Position',addLabelPanelPos,...
                    'Tag','AddLabelPanel');
                else
                    this.AddLabelPanel=uipanel(this.Fig,...
                    'BorderType','none',...
                    'Units','normalized',...
                    'Position',addLabelPanelPos,...
                    'Tag','AddLabelPanel',...
                    'AutoResizeChildren','off');
                end



                addIcon=load(fullfile(toolboxdir('vision'),...
                'vision','+vision','+internal','+labeler','+tool','+icons',...
                'add_icon.mat'));
                addIcon=addIcon.addIcon;
                txt=vision.getMessage('vision:labeler:AddNewFrameLabel');
                this.AddLabelButton=uicontrol('Style','pushbutton',...
                'Parent',this.AddLabelPanel,...
                'Units','char',...
                'FontUnits','normalized',...
                'FontWeight','bold',...
                'FontSize',.80,...
                'ForegroundColor',this.AddButtonTextColor,...
                'CData',addIcon,...
                'Position',buttonPos,...
                'Tag','AddFrameLabelDefinitionButton',...
                'TooltipString',txt);

                width=numel(txt)+sum(isspace(txt))+15;
                textPos=[this.AddLabelButtonWidth+1,3/4,width,1.5];
                this.AddLabelText=uicontrol('style','text',...
                'Parent',this.AddLabelPanel,...
                'Units','char',...
                'HorizontalAlignment','left',...
                'String',txt,...
                'Position',textPos);
            end




            this.LabelSetPanel=vision.internal.labeler.tool.FrameLabelSetPanel(this.Fig,labelSetPanelPos);

            addlistener(this.LabelSetPanel,'ItemSelected',@this.doFrameLabelSelected);
            addlistener(this.LabelSetPanel,'ItemModified',@this.doFrameLabelModified);
            addlistener(this.LabelSetPanel,'ItemRemoved',@this.doPanelItemDeleted);
            addlistener(this.LabelSetPanel,'ItemShrinked',@this.doPanelItemShrinked);
            addlistener(this.LabelSetPanel,'ItemExpanded',@this.doPanelItemExpanded);


            if~useAppContainer
                this.FrameLabelOptionsBGPanel=uipanel(this.Fig,...
                'Units','char',...
                'BorderType','line',...
                'HighlightColor',[0.65,0.65,0.65],...
                'Position',frameOptionsBGPanelPos,...
                'Tag','FrameLabelOptionsBGPanel');

                this.FrameLabelOptionsPanel=uipanel(...
                this.FrameLabelOptionsBGPanel,...
                'Units','normalized',...
                'BorderType','none',...
                'HighlightColor',[0.65,0.65,0.65],...
                'Position',frameOptionsPanelPos,...
                'Tag','FrameLabelOptionsPanel');
            else
                this.FrameLabelOptionsBGPanel=uipanel(this.Fig,...
                'BorderType','line',...
                'Units','normalized',...
                'Position',frameOptionsBGPanelPos,...
                'Tag','FrameLabelOptionsBGPanel',...
                'AutoResizeChildren','off');

                this.FrameLabelOptionsPanel=uipanel(...
                this.FrameLabelOptionsBGPanel,...
                'Units','normalized',...
                'BorderType','none',...
                'Position',frameOptionsPanelPos,...
                'Tag','FrameLabelOptionsPanel',...
                'AutoResizeChildren','off');
            end







            if~strcmpi(this.ToolName,'imageLabeler')


                if~useAppContainer

                    this.FrameLabelOptionGroup=uibuttongroup(...
                    this.FrameLabelOptionsPanel,...
                    'Units','pixels',...
                    'Visible','off',...
                    'BorderType','none',...
                    'Position',[6,1,108,1344]);

                    this.FrameRadioButton=uicontrol(...
                    this.FrameLabelOptionGroup,...
                    'Style','radiobutton',...
                    'String',vision.getMessage('vision:labeler:FrameOption'),...
                    'HorizontalAlignment','left',...
                    'Units','char',...
                    'Position',[0,3,this.RadioButtonWidth,2],...
                    'Tag','SingleFrameRadioButton',...
                    'HandleVisibility','off',...
                    'TooltipString',vision.getMessage('vision:labeler:FrameOptionToolTip'));

                    this.FrameIntervalRadioButton=uicontrol(...
                    this.FrameLabelOptionGroup,...
                    'Style','radiobutton',...
                    'String',vision.getMessage('vision:labeler:IntervalOption'),...
                    'HorizontalAlignment','left',...
                    'Units','char',...
                    'Position',[0,1,this.RadioButtonWidth,2],...
                    'Tag','TimeIntervalRadioButton',...
                    'HandleVisibility','off',...
                    'TooltipString',vision.getMessage('vision:labeler:IntervalOptionToolTip'));
                else
                    set(this.FrameLabelOptionsBGPanel,'Units','pixels');
                    h=this.FrameLabelOptionsBGPanel.Position(4);
                    set(this.FrameLabelOptionsBGPanel,'Units','normalized')
                    set(this.FrameLabelOptionsPanel,'Units','pixels');
                    this.FrameLabelOptionsPanel.Position(1)=1;
                    this.FrameLabelOptionsPanel.Position(4)=h;
                    set(this.FrameLabelOptionsPanel,'Units','normalized');

                    this.FrameLabelOptionGroup=uibuttongroup(...
                    this.FrameLabelOptionsPanel,...
                    'Units','pixels',...
                    'Visible','off',...
                    'BorderType','none',...
                    'Position',[6,1,108,100]);

                    this.FrameRadioButton=uiradiobutton(...
                    this.FrameLabelOptionGroup,...
                    'Text',vision.getMessage('vision:labeler:FrameOption'),...
                    'Position',[1,42,108,28],...
                    'Tag','SingleFrameRadioButton',...
                    'HandleVisibility','off',...
                    'Tooltip',vision.getMessage('vision:labeler:FrameOptionToolTip'));

                    this.FrameIntervalRadioButton=uiradiobutton(...
                    this.FrameLabelOptionGroup,...
                    'Text',vision.getMessage('vision:labeler:IntervalOption'),...
                    'Position',[1,14,108,28],...
                    'Tag','TimeIntervalRadioButton',...
                    'HandleVisibility','off',...
                    'Tooltip',vision.getMessage('vision:labeler:IntervalOptionToolTip'));
                end


                this.FrameLabelOptionGroup.Visible='on';


                frameButtonXPos=this.RadioButtonWidth+2;
            else
                frameButtonXPos=5;
            end

            if strcmpi(this.ToolName,'imageLabeler')
                addFrameLabelText=vision.getMessage('vision:imageLabeler:ApplySceneLabelToImage');
                removeFrameLabelText=vision.getMessage('vision:imageLabeler:RemoveSceneLabelFromImage');
                addFrameLabelToolTip=vision.getMessage('vision:imageLabeler:AddFrameLabelToolTip');
                removeFrameLabelToolTip=vision.getMessage('vision:imageLabeler:RemoveFrameLabelToolTip');


                buttonWidth=this.ActionButtonWidth+4;
            else
                addFrameLabelText=vision.getMessage('vision:labeler:AddFrameLabel');
                removeFrameLabelText=vision.getMessage('vision:labeler:RemoveFrameLabel');
                addFrameLabelToolTip=vision.getMessage('vision:labeler:AddFrameLabelToolTip');
                removeFrameLabelToolTip=vision.getMessage('vision:labeler:RemoveFrameLabelToolTip');
                buttonWidth=this.ActionButtonWidth;
            end


            this.AddFrameLabelButton=uicontrol(...
            'style','pushbutton',...
            'Parent',this.FrameLabelOptionsPanel,...
            'Units','char',...
            'String',addFrameLabelText,...
            'HorizontalAlignment','left',...
            'Position',[frameButtonXPos,3,buttonWidth,2],...
            'Callback',@this.doLabelFrame,...
            'Tag','AddFrameLabelButton',...
            'TooltipString',addFrameLabelToolTip);

            this.RemoveFrameLabelButton=uicontrol(...
            'style','pushbutton',...
            'Parent',this.FrameLabelOptionsPanel,...
            'Units','char',...
            'String',removeFrameLabelText,...
            'HorizontalAlignment','left',...
            'Position',[frameButtonXPos,1,buttonWidth,2],...
            'Callback',@this.doUnlabelFrame,...
            'Tag','RemoveFrameLabelButton',...
            'TooltipString',removeFrameLabelToolTip);

            this.Fig.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;

            this.HelperText=showHelperText(this,vision.getMessage('vision:labeler:FrameHelperText'),helperPos);
        end
    end




    methods(Access=public)




        function configure(this,...
            labelFrameCallback,...
            unlabelFrameCallback,...
            selectionCallback,additionCallBack,...
            modificationCallback,deletionCallback,moveCallback,varargin)

            addlistener(this,'FrameLabeled',labelFrameCallback);

            addlistener(this,'FrameUnlabeled',unlabelFrameCallback);


            addlistener(this,'FrameLabelSelected',selectionCallback);

            addlistener(this,'FrameLabelModified',modificationCallback);

            listenerObj=addlistener(this,'FrameLabelRemoved',deletionCallback);



            listenerObj.Recursive=true;


            addlistener(this,'PanelItemMoved',moveCallback);

            if~isdeployed()

                this.AddLabelButton.Callback=additionCallBack;
            end

            if nargin>8


                keyPressCallback=varargin{1};
                this.Fig.WindowKeyPressFcn=keyPressCallback;
            end

        end

    end




    methods(Access=public)

        function modifyItemName(this,idx,newName,changeDisplay)
            this.LabelSetPanel.modifyItemName(idx,newName,changeDisplay);
        end


        function tf=isValidItemSelected(this)
            if(this.CurrentSelection>0)
                tf=~this.isaGroupItem(this.CurrentSelection);
            else
                tf=false;
            end
        end
    end




    methods(Access=public)
        function freeze(this)
            if~isdeployed()
                this.AddLabelButton.Enable='off';
                this.AddLabelText.Enable='off';
            end
            this.LabelSetPanel.freezeAllItems();
        end


        function unfreeze(this)
            if~isdeployed()
                this.AddLabelButton.Enable='on';
                this.AddLabelText.Enable='on';
            end
            this.LabelSetPanel.unfreezeAllItems();
        end


        function freezeOptionPanel(this)
            if~strcmpi(this.ToolName,'imageLabeler')
                this.FrameRadioButton.Enable='off';
                this.FrameIntervalRadioButton.Enable='off';
            end
            this.AddFrameLabelButton.Enable='off';
            this.RemoveFrameLabelButton.Enable='off';
        end


        function unfreezeOptionPanel(this)
            if~strcmpi(this.ToolName,'imageLabeler')
                this.FrameRadioButton.Enable='on';
                this.FrameIntervalRadioButton.Enable='on';
            end
            this.AddFrameLabelButton.Enable='on';
            this.RemoveFrameLabelButton.Enable='on';
        end
    end




    methods





        function[addLabelPanel,labelSetPanel,buttonPos,...
            optionsPanelPos,optionsBGPanelPos,helperText]=uicontrolPositions(this)






            figPos=hgconvertunits(this.Fig,this.Fig.Position,this.Fig.Units,'char',this.Fig);

            if isdeployed()
                addLabelPanelHeight=0;
            else
                addLabelPanelHeight=this.AddLabelPanelHeight;
            end
            addLabelPanel=[0,figPos(4)-addLabelPanelHeight,figPos(3),addLabelPanelHeight];

            if useAppContainer
                addLabelPanelNormalized=hgconvertunits(this.Fig,addLabelPanel,'char','normalized',this.Fig);
            end

            optionsBGPanelPos=[0,addLabelPanel(2)-this.FrameLabelOptionsPanelHeight...
            ,figPos(3),this.FrameLabelOptionsPanelHeight];

            optionsBGPanelNormalized=hgconvertunits(this.Fig,optionsBGPanelPos,'char','normalized',this.Fig);

            if useAppContainer

                optionsBGPanelPos=optionsBGPanelNormalized;
            end

            helperText=[0.05,optionsBGPanelNormalized(2)-0.25,0.9,0.2];



            w=(this.RadioButtonWidth+this.ActionButtonWidth+5)/figPos(3);
            x=max(0,(1-w)/2);
            optionsPanelPos=[x,0,w,1];



            h=max(0,figPos(4)-addLabelPanel(4)-optionsBGPanelPos(4));
            labelSetPanel=hgconvertunits(this.Fig,[0,0,figPos(3),h],'char','normalized',this.Fig);


            panelPixPos=getpixelposition(this.AddLabelPanel);

            bottom=(panelPixPos(4)-this.AddLabelButtonSizeInPixels(2))/2;



            buttnPixPos=[1,bottom,this.AddLabelButtonSizeInPixels];
            buttonPos=hgconvertunits(this.Fig,buttnPixPos,'pixels','char',this.Fig);

            if useAppContainer
                addLabelPanel=addLabelPanelNormalized;
                labelSetPanel(4)=min(0.8,1-(addLabelPanel(4)+optionsBGPanelPos(4)));
            end

        end

        function updateFrameLabelStatus(this,labelIDs)
            for i=1:this.NumItems
                if~isaGroupItem(this,i)
                    if ismember(i,labelIDs)
                        this.LabelSetPanel.listItemChecked(i);
                    else
                        this.LabelSetPanel.listItemUnchecked(i);
                    end
                else
                    labelIDs=labelIDs+1;
                end
            end
        end

        function remainingUIUpdates(this)


            if this.NumItems>0&&~this.isaGroupItem(this.CurrentSelection)
                unfreezeOptionPanel(this);
            else
                freezeOptionPanel(this);
            end
        end


    end




    methods


        function repositionFrameLabelInRow(this)
            if this.NumItems>0
                [frameColorPanelStartX,frameStatusPanelStartX]=getFrameColorNStatusPanelStartX(this);
                for i=1:this.NumItems
                    if~isaGroupItem(this,i)
                        thisItem=this.LabelSetPanel.Items{i};
                        thisItem.FrameColorPanel.Position(1)=frameColorPanelStartX;
                        thisItem.FrameStatusPanel.Position(1)=frameStatusPanelStartX;

                        maxTextLenInPixel=frameColorPanelStartX-thisItem.FrameTextAndColorXSpacing-thisItem.TextStartX;
                        shortLabel=vision.internal.labeler.tool.shortenLabel(thisItem.FrameLabelText.TooltipString,maxTextLenInPixel);
                        thisItem.FrameLabelText.String=shortLabel;
                    end
                end
            end
        end


        function doPanelPositionUpdate(this)
            [pos1,pos2,buttonPos,pos3,pos4,pos5]=uicontrolPositions(this);
            if~isdeployed()
                this.AddLabelPanel.Position=pos1;
                this.AddLabelButton.Position=buttonPos;
            end
            this.LabelSetPanel.Position=pos2;
            this.FrameLabelOptionsPanel.Position=pos3;
            this.FrameLabelOptionsBGPanel.Position=pos4;
            this.HelperText.Position=pos5;
            repositionFrameLabelInRow(this);
        end


        function[frameColorPanelStartX,frameStatusPanelStartX]=getFrameColorNStatusPanelStartX(this)
            assert(this.NumItems>0);
            w=this.Fig.Position(3);



            itemIdx=find(isaLabelItem(this,1:numel(this.LabelSetPanel.Items)),1);
            itemObj=this.LabelSetPanel.Items{itemIdx};

            if w>itemObj.MinWidth
                if w>itemObj.MaxWidthReqForFrameLabelRow
                    frameColorPanelStartX=itemObj.MaxFrameColorPanelStartX;
                else



                    frameColorPanelStartX=w-itemObj.FrameLabelRowRightClearance...
                    -itemObj.FrameStatusPanel.Position(3)...
                    -itemObj.FrameColorAndStatusXSpacing...
                    -itemObj.FrameColorPanel.Position(3);
                end
            else
                frameColorPanelStartX=itemObj.MinFrameColorPanelStartX;
            end

            frameStatusPanelStartX=frameColorPanelStartX+...
            itemObj.FrameColorPanel.Position(3)+...
            itemObj.FrameColorAndStatusXSpacing;
        end


        function doLabelFrame(this,varargin)

            if this.CurrentSelection==0
                return;
            end
            data=vision.internal.labeler.tool.FrameLabelData;
            data.LabelName=this.LabelSetPanel.Items{this.CurrentSelection}.Data.Label;
            data.ItemId=this.CurrentSelection;

            isVLorGTL=strcmpi(this.ToolName,'videoLabeler')||...
            strcmpi(this.ToolName,'groundTruthLabeler')||...
            strcmpi(this.ToolName,'lidarLabeler');

            isIL=strcmpi(this.ToolName,'imageLabeler');
            if~isIL
                if~useAppContainer
                    condition=this.FrameIntervalRadioButton.Value==this.FrameIntervalRadioButton.Max;
                else
                    condition=this.FrameIntervalRadioButton.Value==1;
                end
            end
            if isVLorGTL&&condition
                data.ApplyToInterval=true;
            else
                data.ApplyToInterval=false;
            end
            notify(this,'FrameLabeled',data);
        end


        function checkFrameLabel(this,labelID)
            this.LabelSetPanel.listItemChecked(labelID);
        end


        function doUnlabelFrame(this,varargin)
            if this.CurrentSelection==0
                return;
            end
            data=vision.internal.labeler.tool.FrameLabelData;
            data.LabelName=this.LabelSetPanel.Items{this.CurrentSelection}.Data.Label;
            data.ItemId=this.CurrentSelection;

            isVLorGTL=strcmpi(this.ToolName,'videoLabeler')||...
            strcmpi(this.ToolName,'groundTruthLabeler')||...
            strcmpi(this.ToolName,'lidarLabeler');

            isIL=strcmpi(this.ToolName,'imageLabeler');

            if~isIL
                if~useAppContainer
                    condition=this.FrameIntervalRadioButton.Value==this.FrameIntervalRadioButton.Max;
                else
                    condition=this.FrameIntervalRadioButton.Value==1;
                end
            end

            if isVLorGTL&&condition
                data.ApplyToInterval=true;
            else
                data.ApplyToInterval=false;
            end
            notify(this,'FrameUnlabeled',data);
        end


        function uncheckFrameLabel(this,labelID)
            this.LabelSetPanel.listItemUnchecked(labelID);
        end


        function doFrameLabelSelected(this,~,data)

            data.Data=this.LabelSetPanel.Items{data.Index}.Data;

            doPanelItemSelected(this,data);


            notify(this,'FrameLabelSelected',data);
        end


        function doFrameLabelModified(this,~,data)

            notify(this,'FrameLabelModified',data);
        end


        function doPanelItemDeleted(this,~,data)

            notify(this,'FrameLabelRemoved',data);
        end


        function flag=isPanelVisible(this)
            flag=strcmpi(this.Fig.Visible,'on');
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end