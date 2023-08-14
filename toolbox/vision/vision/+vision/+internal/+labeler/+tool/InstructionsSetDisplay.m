
classdef InstructionsSetDisplay<vision.internal.uitools.AppFig

    properties(Constant)


        AddLabelButtonHeight=0.8*3;
    end

    properties
InstructionsSetPanel





AddHelpTextWidth
    end


    methods


        function this=InstructionsSetDisplay(hFig)



            nameDisplayedInTab=vision.getMessage(...
            'vision:labeler:InstructionsName');
            this=this@vision.internal.uitools.AppFig(hFig,nameDisplayedInTab,true);
            this.Fig.Resize='on';

            initializeTextWidth(this);

            helpSetPanelPos=uicontrolPositions(this);

            this.InstructionsSetPanel=vision.internal.labeler.tool.InstructionsSetPanel(this.Fig,helpSetPanelPos);
            this.Fig.SizeChangedFcn=@(varargin)this.doPanelPositionUpdate;
        end
    end

    methods





        function helpSetPanel=uicontrolPositions(this)
            figPos=hgconvertunits(this.Fig,this.Fig.Position,this.Fig.Units,'char',this.Fig);



            h=max(0,figPos(4));
            helpSetPanel=hgconvertunits(this.Fig,[0,0,figPos(3),h],'char','normalized',this.Fig);
        end







        function initializeTextWidth(this)



            pos=hgconvertunits(...
            this.Fig,[0,0,0,this.AddLabelButtonHeight],'char','pixels',this.Fig);
            pos=hgconvertunits(this.Fig,[0,0,pos(4),pos(4)],'pixels','char',this.Fig);

            this.AddHelpTextWidth=pos(3);
        end

        function flag=isAttribute(~,data)
            flag=isstruct(data);
        end

        function renderAttributes(this,attribData)
            for i=1:length(attribData)
                appendItem(this,attribData{i});
            end
        end


        function updateItem(this)
            this.InstructionsSetPanel.updateItem();
        end


        function appendItem(this,data)
            this.InstructionsSetPanel.appendItem(data);
        end


        function deleteItem(this,data)
            this.InstructionsSetPanel.deleteItem(data);
        end


        function deleteAllItems(this)

            this.InstructionsSetPanel.deleteAllItems();
        end


        function flag=isPanelVisible(this)
            flag=strcmpi(this.Fig.Visible,'on');
        end
    end





    methods
        function doPanelPositionUpdate(this)
            pos=uicontrolPositions(this);
            this.InstructionsSetPanel.Position=pos;
        end
    end
end
