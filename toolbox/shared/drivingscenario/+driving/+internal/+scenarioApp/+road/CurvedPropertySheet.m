classdef CurvedPropertySheet<driving.internal.scenarioApp.road.PropertySheet&...
    driving.internal.scenarioApp.road.LanesWidgets

    properties(Hidden)
hWidth
hRadius
        MinWidth=0
hEndPoint
hStartPoint
    end

    methods
        function this=CurvedPropertySheet(varargin)
            this@driving.internal.scenarioApp.road.PropertySheet(varargin{:});
        end

        function update(this)
            road=getSpecification(this);
            setupWidgets(this,road,{'Width','Radius','StartPoint','EndPoint'});
            update@driving.internal.scenarioApp.road.LanesWidgets(this);
        end

        function updateLayout(this)
            updateLayout@driving.internal.scenarioApp.road.LanesWidgets(this);
            vw=[0,0,0,0,1];
            if this.ShowLanes
                vw=[0,vw];
            end
            this.Layout.VerticalWeights=vw;
        end

        function w=getLabelMinimumWidth(this)
            w=this.MinWidth;
        end
    end

    methods(Access=protected)
        function createWidgets(this)
            p=this.Panel;

            hWidthLabel=createLabelEditPair(this,p,'Width');
            hStartLabel=createLabelEditPair(this,p,'StartPoint');
            hEndLabel=createLabelEditPair(this,p,'EndPoint');
            hRadiusLabel=createLabelEditPair(this,p,'Radius');

            flipButton=uicontrol(p,...
            'Style','pushbutton',...
            'String','S',...
            'Callback',@this.flipCallback);

            createWidgets@driving.internal.scenarioApp.road.LanesWidgets(this);

            layout=matlabshared.application.layout.GridBagLayout(p,...
            'VerticalWeights',[0,0,0,0,1],...
            'HorizontalWeights',[0,1,0],...
            'VerticalGap',3);

            labelWidth=layout.getMinimumWidth([hWidthLabel,hRadiusLabel,hStartLabel,hEndLabel]);

            this.Layout=layout;
            this.MinWidth=labelWidth;

            labelInset=3;
            labelHeight=20-labelInset;

            layout.add(hWidthLabel,1,1,...
            'TopInset',labelInset,...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth);
            layout.add(this.hWidth,1,[2,3],...
            'Fill','Horizontal');

            layout.add(hStartLabel,2,1,...
            'TopInset',labelInset,...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth,...
            'Anchor','NorthWest');
            layout.add(this.hStartPoint,2,2,...
            'Fill','Horizontal',...
            'Anchor','NorthEast');
            layout.add(hEndLabel,3,1,...
            'TopInset',labelInset,...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth,...
            'Anchor','NorthWest');
            layout.add(this.hEndPoint,3,2,...
            'Fill','Horizontal',...
            'Anchor','NorthEast');
            layout.add(flipButton,[2,3],3,...
            'MinimumWidth',20,...
            'Fill','Vertical');
            layout.add(hRadiusLabel,4,1,...
            'TopInset',labelInset,...
            'MinimumHeight',labelHeight,...
            'MinimumWidth',labelWidth,...
            'Anchor','NorthWest');
            layout.add(this.hRadius,4,[2,3],...
            'Fill','Horizontal',...
            'Anchor','NorthEast');

            addLanesWidgetsToLayout(this,5);
        end

        function flipCallback(this,~,~)
            spec=getSpecification(this);
            setProperty(this.Dialog,{'StartPoint','EndPoint'},{spec.EndPoint,spec.StartPoint});
            update(this);
        end
    end
end


