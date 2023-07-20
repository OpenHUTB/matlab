classdef BaseAgentPnl<panels.PanelBase


    properties

BaseAgentPanel

    end

    properties(Access=private)
WidthField
HeightField
ResField
PadField
    end

    methods
        function obj=BaseAgentPnl(mapDataMngr,grid,row,col)


            obj.BaseAgentPanel=uipanel(grid,...
            'Title',"Base Agent Properties",...
            'FontWeight','bold',...
            'BorderType','none');
            obj.BaseAgentPanel.Layout.Row=row;
            obj.BaseAgentPanel.Layout.Column=col;
            obj.BaseAgentPanel.Scrollable='off';
            obj.BaseAgentPanel.Enable='off';
            obj.MapDataMngr=mapDataMngr;

            obj=obj.addContents();
        end

        function obj=addContents(obj)


            BaseAgentPnlGrid=uigridlayout(obj.BaseAgentPanel,[6,4]);
            BaseAgentPnlGrid.RowHeight={22,22,22,22,22,22};
            BaseAgentPnlGrid.ColumnWidth={'1x','2x','1x','2x'};

            descLabel=uilabel(BaseAgentPnlGrid,...
            'Text','Configure and preview your agent in the map');
            descLabel.Layout.Row=1;
            descLabel.Layout.Column=[1,4];

            XLabel=uilabel(BaseAgentPnlGrid,"Text",'Preview');
            XLabel.Layout.Row=2;
            XLabel.Layout.Column=1;

            previewButtonGrp=uibuttongroup(BaseAgentPnlGrid,"BorderType","none",...
            "SelectionChangedFcn",@(src,event)obj.MapDataMngr.setBaseAgentPreview(event),...
            "CreateFcn",@(src,event)obj.MapDataMngr.setBaseAgentPreview(event),'Tooltip','Preview the base agent on the map');
            previewButtonGrp.Layout.Row=2;
            previewButtonGrp.Layout.Column=2;

            onBtn=uiradiobutton(previewButtonGrp,"Text",'On',...
            'Position',[10,0,50,22],'Tag','On');

            offBtn=uiradiobutton(previewButtonGrp,"Text",'Off',...
            'Position',[50,0,50,22],'Tag','Off');

            XLabel=uilabel(BaseAgentPnlGrid,"Text",'X');
            XLabel.Layout.Row=3;
            XLabel.Layout.Column=1;

            XField=uispinner(BaseAgentPnlGrid,"Value",10,"Limits",[0,inf],'Tooltip','X position of the base agent preview');
            XField.ValueChangedFcn=@(src,event)obj.MapDataMngr.setBaseAgentX(XField.Value);
            XField.Layout.Row=3;
            XField.Layout.Column=2;

            YLabel=uilabel(BaseAgentPnlGrid,"Text",'Y');
            YLabel.Layout.Row=3;
            YLabel.Layout.Column=3;

            YField=uispinner(BaseAgentPnlGrid,"Value",5,"Limits",[0,inf],'Tooltip','Y position of the base agent preview');
            YField.ValueChangedFcn=@(src,event)obj.MapDataMngr.setBaseAgentY(YField.Value);
            YField.Layout.Row=3;
            YField.Layout.Column=4;

            WidthLabel=uilabel(BaseAgentPnlGrid,"Text",'Width');
            WidthLabel.Layout.Row=4;
            WidthLabel.Layout.Column=1;

            obj.WidthField=uispinner(BaseAgentPnlGrid,"Value",2,"Limits",[0,inf],'Tooltip','Width of the base agent');
            obj.WidthField.ValueChangedFcn=@(src,evnt)obj.MapDataMngr.setBaseAgentWidth(obj.WidthField.Value);
            obj.WidthField.Layout.Row=4;
            obj.WidthField.Layout.Column=2;

            HeightLabel=uilabel(BaseAgentPnlGrid,"Text",'Height');
            HeightLabel.Layout.Row=4;
            HeightLabel.Layout.Column=3;

            obj.HeightField=uispinner(BaseAgentPnlGrid,"Value",1,"Limits",[0,inf],'Tooltip','Height of the base agent');
            obj.HeightField.ValueChangedFcn=@(src,evnt)obj.MapDataMngr.setBaseAgentHeight(obj.HeightField.Value);
            obj.HeightField.Layout.Row=4;
            obj.HeightField.Layout.Column=4;

            padLabel=uilabel(BaseAgentPnlGrid,'Text','Padding');
            padLabel.Layout.Row=5;
            padLabel.Layout.Column=1;

            obj.PadField=uispinner(BaseAgentPnlGrid,'Value',1.5,...
            "CreateFcn",@(src,evnt)obj.MapDataMngr.setBaseAgentPadding(1.5),"Limits",[0,inf],'Tooltip','Padding around the base agent as a footprint multiplier');
            obj.PadField.ValueChangedFcn=@(src,evnt)obj.MapDataMngr.setBaseAgentPadding(obj.PadField.Value);
            obj.PadField.Layout.Row=5;
            obj.PadField.Layout.Column=2;

            resLabel=uilabel(BaseAgentPnlGrid,'Text','Reservation');
            resLabel.Layout.Row=6;
            resLabel.Layout.Column=1;

            obj.ResField=uispinner(BaseAgentPnlGrid,'Value',2,"Limits",[0,inf],'Tooltip','Blocks reserved on either side of the agent');
            obj.ResField.ValueChangedFcn=@(src,evnt)obj.MapDataMngr.setBaseAgentReservation(obj.ResField.Value);
            obj.ResField.Layout.Row=6;
            obj.ResField.Layout.Column=2;

            resDesc=uilabel(BaseAgentPnlGrid,'Text','(Single side spacing)');
            resDesc.Layout.Row=6;
            resDesc.Layout.Column=[3,4];
        end

        function updateValues(obj,values)
            obj.WidthField.Value=values.Width;
            obj.HeightField.Value=values.Height;
            obj.ResField.Value=values.Reservation;
            obj.PadField.Value=values.Padding;
        end
    end
end

