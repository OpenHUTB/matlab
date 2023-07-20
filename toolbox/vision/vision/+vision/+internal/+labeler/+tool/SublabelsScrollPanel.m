
classdef SublabelsScrollPanel<vision.internal.labeler.tool.ScrollableList

    properties
TitlePanel
hFig
    end

    methods

        function this=SublabelsScrollPanel(parent,position)
            itemFactory=vision.internal.labeler.tool.SublabelsItemFactory();

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
            this.FixedPanel.Tag='SublabelsScrollPanel';
        end


        function posTitlePanel=getTitlePanelPosition(this)
            pos=positionInPixel(this.FixedPanel);
            posTitlePanel=[pos(1)+10,pos(2)+pos(4)-12,70,20];
        end


        function setTitle(this)
            posTitlePanel=getTitlePanelPosition(this);
            if~useAppContainer
                this.TitlePanel=uipanel('parent',this.hFig,'units','pixels',...
                'position',posTitlePanel,'backgroundcolor',[1,1,0],'BorderWidth',0,...
                'Tag','SublabelSummaryTitlePanel');
            else
                this.TitlePanel=uipanel('Parent',this.hFig,'Units','Pixels',...
                'Position',posTitlePanel,'Backgroundcolor',[1,1,0],...
                'Tag','SublabelSummaryTitlePanel');
            end
            uicontrol(this.TitlePanel,'Style','text',...
            'String',getString(message('vision:labeler:Sublabels')),...
            'units','normalized','position',[0,0,1,1],'HorizontalAlignment','left');
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


        function disableAllItems(this)

            if this.NumItems>0
                for idx=1:this.NumItems
                    disable(this.Items{idx});
                    if~isequal(this.DisabledItems,0)
                        this.DisabledItems=[this.DisabledItems,idx];
                    else
                        this.DisabledItems=idx;
                    end
                end

                update(this);
            end
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
