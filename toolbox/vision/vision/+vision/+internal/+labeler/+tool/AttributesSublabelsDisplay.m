
classdef AttributesSublabelsDisplay<vision.internal.uitools.AppFig

    properties(Constant)


        AddLabelButtonHeight=0.8*3;
    end

    properties
        PanelDetail=struct('UIPanel',[],'ParentText',[],'LabelSublabelColor',[],'LabelSublabelText',[]);

AttributesScrollPanel
SublabelsScrollPanel



AddHelpTextWidth

PanelDetailPos
AttribScrollPanelPos
SublabelScrollPanelPos
        OffsetFromTop=45;
        OffsetFromMiddle=10;
    end

    events

AttributePanelItemModified
    end




    methods

        function this=AttributesSublabelsDisplay(hFig)

            nameDisplayedInTab=vision.getMessage('vision:labeler:AttributesAndSublabels');
            this=this@vision.internal.uitools.AppFig(hFig,nameDisplayedInTab,true);


            if useAppContainer
                this.Fig.AutoResizeChildren='off';
            end
            this.Fig.Resize='on';


            initializeTextWidth(this);



            computeUIcontrolPositions(this);
            createAttributeDetailsTextBox(this);
            createAttributesPanel(this);
            createSublabelsPanel(this);

            this.Fig.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;
            addlistener(this.AttributesScrollPanel,'ItemModified',@this.doAttributePanelItemModified);
        end
    end




    methods

        function configure(this,modificationCallback,varargin)
            addlistener(this,'AttributePanelItemModified',modificationCallback);

            if nargin>2
                keyPressCallback=varargin{1};
                this.Fig.KeyPressFcn=keyPressCallback;
            end
        end


        function createAttributeDetailsTextBox(this)
            if~useAppContainer
                this.PanelDetail.UIPanel=uipanel('parent',this.Fig,...
                'BorderWidth',0,...
                'units','pixels','position',this.PanelDetailPos.Pixels);

                this.PanelDetail.LabelSublabelColor=uipanel('parent',this.PanelDetail.UIPanel,...
                'BorderWidth',0,...
                'Tag','ASDPanelDetailColor',...
                'units','pixels','position',[5,4,8,16]);
            else
                this.PanelDetail.UIPanel=uipanel('parent',this.Fig,...
                'Units','pixels','Position',this.PanelDetailPos.Pixels);

                this.PanelDetail.LabelSublabelColor=uipanel('parent',this.PanelDetail.UIPanel,...
                'Tag','ASDPanelDetailColor',...
                'Units','Pixels','Position',[5,4,8,16]);
            end

            this.PanelDetail.ParentText=uicontrol('Style','text','parent',this.PanelDetail.UIPanel,...
            'units','pixels','position',[5,24,100,14],...
            'HorizontalAlignment','left',...
            'String','',...
            'FontSize',8,...
            'Tag','PanelDetail_ParentText');

            this.PanelDetail.LabelSublabelText=uicontrol('Style','text','parent',this.PanelDetail.UIPanel,...
            'units','pixels','position',[17,2,140,20],...
            'HorizontalAlignment','left',...
            'String','',...
            'FontWeight','bold',...
            'FontSize',12,...
            'Tag','ASDPanelDetail');

            this.PanelDetail.SignalHeading=uicontrol('Style','text','parent',this.PanelDetail.UIPanel,...
            'units','pixels','position',[5,25,100,20],...
            'HorizontalAlignment','left',...
            'String','Signal Name :',...
            'FontWeight','bold',...
            'FontSize',9,...
            'Tag','ASDPanelDetail',...
            'Visible','off');

            this.PanelDetail.SignalText=uicontrol('Style','text','parent',this.PanelDetail.UIPanel,...
            'units','pixels','position',[110,25,300,20],...
            'HorizontalAlignment','left',...
            'String','',...
            'FontWeight','normal',...
            'FontSize',9,...
            'Tag','ASDPanelDetail',...
            'Visible','off');
        end


        function createAttributesPanel(this)
            this.AttributesScrollPanel=vision.internal.labeler.tool.AttributesScrollPanel(this.Fig,this.AttribScrollPanelPos.Norm);
            this.AttributesScrollPanel.setBorder();
            this.AttributesScrollPanel.setTitle();
        end


        function createSublabelsPanel(this)
            this.SublabelsScrollPanel=vision.internal.labeler.tool.SublabelsScrollPanel(this.Fig,this.SublabelScrollPanelPos.Norm);
            this.SublabelsScrollPanel.setBorder();
            this.SublabelsScrollPanel.setTitle();
        end






        function pos=getFigurePosInPixel(this)
            origUnit=this.Fig.Units;
            this.Fig.Units='pixels';
            pos=this.Fig.Position;
            this.Fig.Units=origUnit;
        end


        function computeUIcontrolPositions(this)
            figPos=getFigurePosInPixel(this);
            figW=figPos(3);
            figH=figPos(4);
            offset=6;

            x=offset;
            y=figH-offset-this.OffsetFromTop;
            w=max(0,figW-2*offset);
            h=this.OffsetFromTop;
            this.PanelDetailPos.Pixels=[x,y,w,h];
            this.PanelDetailPos.Norm=[x/figW,y/figH,w/figW,h/figH];


            x=offset;
            y=(figH-2*offset-this.OffsetFromTop)/2;
            w=max(0,figW-2*offset);
            h=(figH-2*offset-this.OffsetFromTop)/2-offset;
            h=max(0,h);
            this.AttribScrollPanelPos.Pixels=[x,y,w,h];
            this.AttribScrollPanelPos.Norm=[x/figW,y/figH,w/figW,h/figH];


            x=offset;
            y=offset;
            w=max(0,figW-2*offset);
            h=(figH-2*offset-this.OffsetFromTop)/2-this.OffsetFromMiddle-offset;
            h=max(0,h);
            this.SublabelScrollPanelPos.Pixels=[x,y,w,h];
            this.SublabelScrollPanelPos.Norm=[x/figW,y/figH,w/figW,h/figH];
        end






        function sublabelScrollPanelPos=uicontrolPositionsForSublabel(~)


            sublabelScrollPanelPos=[0,0,1,0.45];
        end







        function initializeTextWidth(this)



            pos=hgconvertunits(...
            this.Fig,[0,0,0,this.AddLabelButtonHeight],'char','pixels',this.Fig);
            pos=hgconvertunits(this.Fig,[0,0,pos(4),pos(4)],'pixels','char',this.Fig);

            this.AddHelpTextWidth=pos(3);
        end


        function appendItem(this,data)
            this.AttributesScrollPanel.appendItem(data);
            this.AttributesScrollPanel.updateItem();
        end


        function deleteItem(this,data)
            this.AttributesScrollPanel.deleteItem(data);
        end


        function itemID=getItemID(this,attributeName)
            itemID=this.AttributesScrollPanel.getItemID(attributeName);
        end

        function deleteItemWithID(this,attribItemID)
            this.AttributesScrollPanel.deleteItemWithID(attribItemID);
        end


        function deleteAllItems(this)
            this.AttributesScrollPanel.deleteAllItems();
            this.SublabelsScrollPanel.deleteAllItems();
        end


        function modifyLabelName(this,newLabelName)


            if~isempty(this.PanelDetail.ParentText.String)
                this.PanelDetail.ParentText.String=newLabelName;
            else
                this.PanelDetail.LabelSublabelText.String=newLabelName;
            end


            updateFirstItemTextIfNeeded(this,newLabelName,'');


            noSublabelText=vision.getMessage('vision:labeler:LabelWithNoSublabel',newLabelName);
            this.SublabelsScrollPanel.updateItemDataValue(1,noSublabelText);
        end


        function modifyListAttributeItems(this,oldAttribData,val)
            itemID=this.AttributesScrollPanel.getItemID(oldAttribData.Name);
            this.AttributesScrollPanel.modifyListItemDataValue(itemID,val);
        end


        function modifyAttributeName(this,oldAttribData,newName)
            itemID=this.AttributesScrollPanel.getItemID(oldAttribData.Name);
            this.AttributesScrollPanel.modifyItemData(itemID,newName);
        end


        function modifyAttributeDescription(this,oldAttribData,newDescription)
            itemID=this.AttributesScrollPanel.getItemID(oldAttribData.Name);
            this.AttributesScrollPanel.modifyDescriptionValue(itemID,newDescription);
        end


        function appendAttribute(this,attribData)
            if this.AttributesScrollPanel.NumItems==1


                this.AttributesScrollPanel.deleteAllItems();
                this.AttributesScrollPanel.appendItem('');
                this.AttributesScrollPanel.appendItem(attribData);
            else
                this.AttributesScrollPanel.appendItem(attribData);
            end
            this.AttributesScrollPanel.updateItem();
        end


        function appendSublabelInfo(this,sublabelData)
            this.SublabelsScrollPanel.appendItem(sublabelData);
            this.SublabelsScrollPanel.updateItem();
        end


        function updateFirstItemTextIfNeeded(this,labelName,sublabelName)
            if this.AttributesScrollPanel.NumItems==1
                headerNone=this.formHeaderTextForAttributes(labelName,sublabelName,[]);
                this.AttributesScrollPanel.updateFirstItemData(headerNone);
            end
        end


        function disableAttribPanel(this)
            this.AttributesScrollPanel.disableAllItems();
        end


        function enableAttribPanel(this)
            this.AttributesScrollPanel.enableAllItems();
        end


        function deleteSublabelInfoItems(this)
            this.SublabelsScrollPanel.deleteAllItems();
        end


        function showNoSublabelAllowedMessage(this)
            noSublabelText=vision.getMessage('vision:labeler:SublabelNoSublabel');
            this.SublabelsScrollPanel.appendItem(noSublabelText);
            this.SublabelsScrollPanel.updateItem();
        end


        function TF=needAttribItemRecreation(this,labelName,sublabelName,attribDefData)
            TF=false;
            numItems=this.AttributesScrollPanel.NumItems;



            if~this.AttributesScrollPanel.isSameLabelAndSublabel(labelName,sublabelName)||...
                (numItems~=(length(attribDefData)+1))
                TF=true;
            end
        end


        function needToRecreateItem=needSublabelItemRecreation(this,labelName,sublabelNames)
            existingLabelName=this.SublabelsScrollPanel.getRootName();
            if~strcmp(labelName,existingLabelName)
                needToRecreateItem=true;
            else
                existingSublabelNames=this.SublabelsScrollPanel.getItemDataNames();
                needToRecreateItem=~isequal(sublabelNames,existingSublabelNames);
            end
        end


        function updatePanelDetail(this,labelName,sublabelName,itemColor)

            if nargin<4

                this.PanelDetail.ParentText.String='';
                this.PanelDetail.LabelSublabelText.String='';
                this.PanelDetail.LabelSublabelColor.BackgroundColor=[0.94,0.94,0.94];
                return;
            end

            if~isempty(sublabelName)
                parentname=labelName;
                itemName=sublabelName;
            else
                parentname='';
                itemName=labelName;
            end
            this.PanelDetail.ParentText.String=parentname;
            if~isempty(itemColor)
                this.PanelDetail.LabelSublabelColor.BackgroundColor=itemColor;
            end
            this.PanelDetail.LabelSublabelText.String=itemName;
        end


        function updatePanelSignal(this,signalName)

            this.PanelDetail.SignalText.String=signalName;
        end


        function updateVisibilityOfSignal(this,count)
            if count>1
                this.PanelDetail.SignalHeading.Visible='on';
                this.PanelDetail.SignalText.Visible='on';
            else
                this.PanelDetail.SignalHeading.Visible='off';
                this.PanelDetail.SignalText.Visible='off';
            end
        end


        function updateAttribInAttributesSublabelsPanel(this,labelName,sublabelName,attribDefData,attribInstanceData)



            if nargin<5

                this.AttributesScrollPanel.deleteAllItems();

                text=vision.getMessage('vision:labeler:GroupItemAttrDisplayMessage');
                this.AttributesScrollPanel.appendItem(text);
                this.AttributesScrollPanel.updateItem();
                return;
            end

            headerNone=this.formHeaderTextForAttributes(labelName,sublabelName,attribDefData);
            needToRecreateItem=needAttribItemRecreation(this,labelName,sublabelName,attribDefData);
            if needToRecreateItem

                this.AttributesScrollPanel.deleteAllItems();
                this.AttributesScrollPanel.setLabelName(labelName);
                this.AttributesScrollPanel.setSublabelName(sublabelName);
                this.AttributesScrollPanel.appendItem(headerNone);
                for i=1:length(attribDefData)
                    this.AttributesScrollPanel.appendItem(attribDefData{i});
                end
                this.AttributesScrollPanel.updateItem();
            end


            for i=1:length(attribInstanceData)
                itemID=i+1;
                attribVal=getCorrectAttribVal(attribDefData{i},attribInstanceData{i});
                if iscell(attribInstanceData{i}.Value)
                    this.AttributesScrollPanel.updateItemDataValue(itemID,1);
                else
                    this.AttributesScrollPanel.updateItemDataValue(itemID,attribVal);
                end
            end
        end


        function updateSublblInAttributesSublabelsPanel(this,labelName,sublabelNames,isPixelLabel,numSublabelInstances,forROIInstance)



            if nargin<5

                this.SublabelsScrollPanel.deleteAllItems();

                text=vision.getMessage('vision:labeler:GroupItemSublDisplayMessage');
                this.SublabelsScrollPanel.appendItem(text);

                this.SublabelsScrollPanel.updateItem();
                return;
            end

            needToRecreateItem=needSublabelItemRecreation(this,labelName,sublabelNames);
            if needToRecreateItem

                this.SublabelsScrollPanel.deleteAllItems();

                if isempty(sublabelNames)
                    if isPixelLabel
                        noSublabelText=vision.getMessage('vision:labeler:PixelLabelNoSublabel');
                    else
                        noSublabelText=vision.getMessage('vision:labeler:LabelWithNoSublabel',labelName);
                    end
                    this.SublabelsScrollPanel.appendItem(noSublabelText);
                end
            end

            for i=1:length(sublabelNames)
                sublabelData.LabelName=labelName;
                sublabelData.SublabelName=sublabelNames{i};
                sublabelData.NumSublabelInstances=numSublabelInstances(i);
                sublabelData.ForROIInstance=forROIInstance;

                if needToRecreateItem
                    this.SublabelsScrollPanel.appendItem(sublabelData);
                else
                    this.SublabelsScrollPanel.updateItemDataValue(i,sublabelData);
                end

            end
            this.SublabelsScrollPanel.updateItem();
        end


        function makePanelVisible(this)
            this.Fig.Visible='on';
        end

        function flag=isPanelVisible(this)
            flag=false;
            if isvalid(this.Fig)
                flag=strcmpi(this.Fig.Visible,'on');
            end
        end


        function doAttributePanelItemModified(this,~,data)

            notify(this,'AttributePanelItemModified',data);
        end


        function updatePanelDetailPosition(this,pos)
            origunit=this.PanelDetail.UIPanel.Units;
            this.PanelDetail.UIPanel.Units='pixels';
            this.PanelDetail.UIPanel.Position=pos.Pixels;
            this.PanelDetail.UIPanel.Units=origunit;
        end
    end




    methods

        function doPanelPositionUpdate(this)

            computeUIcontrolPositions(this);
            this.updatePanelDetailPosition(this.PanelDetailPos);

            this.AttributesScrollPanel.updatePosition(this.AttribScrollPanelPos);
            this.AttributesScrollPanel.update();

            this.SublabelsScrollPanel.updatePosition(this.SublabelScrollPanelPos);
            this.SublabelsScrollPanel.update();
        end
    end

    methods(Static)

        function headerNone=formHeaderTextForAttributes(labelName,sublabelName,attribData)
            if isempty(sublabelName)
                if isempty(attribData)
                    headerNone=vision.getMessage('vision:labeler:AttributeForLabelNone',labelName);
                else

                    headerNone='';
                end
            else
                if isempty(attribData)
                    headerNone=vision.getMessage('vision:labeler:AttributeForLabelNone',sublabelName);
                else

                    headerNone='';
                end
            end
        end
    end
end


function attribVal=getCorrectAttribVal(attribDefDatum,attribInstanceDatum)

    defaultVal=attribDefDatum.Value;
    instanceVal=attribInstanceDatum.Value;
    attribType=attribDefDatum.Type;

    if((attribType==attributeType.List)||(attribType==attributeType.Logical))&&...
        (iscell(instanceVal)||isempty(instanceVal))

        if isnumeric(defaultVal)&&(~isempty(defaultVal))
            attribVal=defaultVal;
        else
            attribVal=1;
        end
    elseif((attribType==attributeType.String)||(attribType==attributeType.Numeric))&&...
        (isnumeric(instanceVal)&&isempty(instanceVal))


        attribVal=defaultVal;
    else
        attribVal=instanceVal;
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end