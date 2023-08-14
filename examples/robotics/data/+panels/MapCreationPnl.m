classdef MapCreationPnl<panels.PanelBase


    properties

CreationPanel
    end

    properties(Access=private)

width


height


gridSpacing

units
    end

    methods
        function obj=MapCreationPnl(mapDataMgr,grid,row,col)



            obj.CreationPanel=uipanel(grid,...
            'Title',"Occupancy Map",...
            'FontWeight','bold',...
            'BorderType','none');
            obj.CreationPanel.Layout.Row=row;
            obj.CreationPanel.Layout.Column=col;
            obj.CreationPanel.Scrollable='off';
            obj.MapDataMngr=mapDataMgr;
            obj.addContents;
        end

        function addContents(obj)


            CreationPanelGrid=uigridlayout(obj.CreationPanel,[4,4]);
            CreationPanelGrid.RowHeight={22,22,22,22};
            CreationPanelGrid.ColumnWidth={'fit','fit','fit','fit'};


            obj.width=60;
            obj.height=60;
            obj.gridSpacing=1;
            obj.units='meters';


            label=uilabel(CreationPanelGrid,'Text','Define and Create an empty Occupancy Map (all values in meters)');
            label.Layout.Row=1;
            label.Layout.Column=[1,4];


            widthLabel=uilabel(CreationPanelGrid,'Text','Width');
            widthField=uispinner(CreationPanelGrid,'Value',obj.width,'Tooltip','Map width in meters');
            widthField.ValueChangedFcn=@(src,event)obj.MapDataMngr.setWidth(widthField.Value);
            widthField.Limits=[0,inf];
            widthField.LowerLimitInclusive='off';

            heightLabel=uilabel(CreationPanelGrid,'Text','Height');
            heightField=uispinner(CreationPanelGrid,'Value',obj.height,'Tooltip','Map height in meters');
            heightField.ValueChangedFcn=@(src,event)obj.MapDataMngr.setHeight(heightField.Value);
            heightField.Limits=[0,inf];
            widthField.LowerLimitInclusive='off';


            gridSpacingLabel=uilabel(CreationPanelGrid,'Text','Grid Spacing');
            gridSpacingField=uispinner(CreationPanelGrid,'Value',obj.gridSpacing,'Tooltip','Distance between grids in meters');
            gridSpacingField.ValueChangedFcn=@(src,event)obj.MapDataMngr.setGridSpacing(gridSpacingField.Value);
            gridSpacingField.Layout.Column=[2,4];
            gridSpacingField.Limits=[0,inf];


            createButton=uibutton(CreationPanelGrid,"Text",'Create Map',...
            'ButtonPushedFcn',@(btn,event)obj.MapDataMngr.createMap());
            createButton.Layout.Column=[1,2];
            clearButton=uibutton(CreationPanelGrid,"Text",'Clear Map',...
            'ButtonPushedFcn',@(btn,event)obj.MapDataMngr.clearMap());
            clearButton.Layout.Column=[3,4];

        end
    end
end

