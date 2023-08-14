
classdef AttributesScrollPanel<vision.internal.labeler.tool.ScrollableList

    properties
TitlePanel
hFig
    end

    properties(Access=private)
LabelName
SublabelName
    end

    methods

        function this=AttributesScrollPanel(parent,position)
            itemFactory=vision.internal.labeler.tool.AttributesItemFactory();

            this=this@vision.internal.labeler.tool.ScrollableList(...
            parent,position,itemFactory);

            this.hFig=ancestor(this.FixedPanel,'figure');
            this.hFig.Color=[0.94,0.94,0.94];
        end


        function setBorder(this)
            if~useAppContainer
                this.FixedPanel.BorderType='etchedin';
            else
                this.FixedPanel.BorderType='line';
            end
            this.FixedPanel.Tag='AttributesScrollPanel';
        end


        function posTitlePanel=getTitlePanelPosition(this)
            pos=positionInPixel(this.FixedPanel);
            posTitlePanel=[pos(1)+10,pos(2)+pos(4)-12,70,20];
        end


        function setTitle(this)
            posTitlePanel=getTitlePanelPosition(this);
            if~useAppContainer
                this.TitlePanel=uipanel('Parent',this.hFig,'Units','Pixels',...
                'Position',posTitlePanel,'Backgroundcolor',[1,1,0],'BorderWidth',0,...
                'Tag','AttributeTitlePanel');
            else
                this.TitlePanel=uipanel('Parent',this.hFig,'Units','Pixels',...
                'Position',posTitlePanel,'Backgroundcolor',[1,1,0],...
                'Tag','AttributeTitlePanel');
            end

            uicontrol(this.TitlePanel,'Style','text',...
            'String',getString(message('vision:labeler:Attributes')),...
            'units','normalized','position',[0,0,1,1],'HorizontalAlignment','left');
        end


        function setLabelName(this,labelName)
            this.LabelName=labelName;
        end


        function setSublabelName(this,sublabelName)
            this.SublabelName=sublabelName;
        end


        function updateList(this,~,val)
            this.Value=val;
        end


        function TF=isSameLabelAndSublabel(this,labelName,sublabelName)
            TF=false;

            if(strcmp(labelName,this.LabelName)&&strcmp(sublabelName,this.SublabelName))
                TF=true;
            end
        end


        function updateTitlePosition(this)
            posTitlePanel=getTitlePanelPosition(this);
            this.TitlePanel.Position=posTitlePanel;
        end


        function updateFixedPanelPosition(this,pos)
            origunit=this.FixedPanel.Units;
            this.FixedPanel.Units='pixels';
            this.FixedPanel.Position=pos.Pixels;
            this.FixedPanel.Units=origunit;
        end


        function updatePosition(this,pos)
            updateFixedPanelPosition(this,pos);
            updateTitlePosition(this);
        end



        function modifyListItemDataValue(this,itemID,val)
            if(itemID<=this.NumItems)
                modifyListDataValue(this.Items{itemID},val);
            end
        end


        function modifyDescriptionValue(this,itemID,val)
            modifyDescription(this.Items{itemID},val);
        end
    end
end


function pos=positionInPixel(obj)

    origUnit=obj.Units;
    obj.Units='pixels';
    pos=obj.Position;
    obj.Units=origUnit;

end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end
