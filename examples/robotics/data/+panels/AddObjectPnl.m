classdef AddObjectPnl<panels.PanelBase



    properties
AddObjPanel

ObjTable
    end

    methods
        function obj=AddObjectPnl(mapDataMngr,grid,row,col)



            obj.AddObjPanel=uipanel(grid,...
            'Title',"Add Objects To Map",...
            'FontWeight','bold',...
            'BorderType','none');
            obj.AddObjPanel.Layout.Row=row;
            obj.AddObjPanel.Layout.Column=col;
            obj.AddObjPanel.Scrollable='on';
            obj.AddObjPanel.Enable='off';
            obj.MapDataMngr=mapDataMngr;

            obj=obj.addContents;
        end

        function obj=addContents(obj)


            AddObjPanelGrid=uigridlayout(obj.AddObjPanel,[5,1],'Scrollable','on');
            AddObjPanelGrid.RowHeight={44,44,22,200};
            AddObjPanelGrid.ColumnWidth={'1x'};

            description=uilabel(AddObjPanelGrid,'WordWrap','on','Text','Select an object type, and place it on the map by left clicking. Right click an object to remove it. Coordinates refer to the top left corner of an object.');
            description.Layout.Row=1;

            objButtons=uibuttongroup(AddObjPanelGrid,"SelectionChangedFcn",@(btn,src)obj.MapDataMngr.objSelectorChanged(btn));
            objButtons.Layout.Row=2;

            lsBtn=uiradiobutton(objButtons,"Text",'Loading Station',...
            'WordWrap','on','Position',[10,10,91,22]);

            usBtn=uiradiobutton(objButtons,"Text",'Unloading Station',...
            'WordWrap','on','Position',[110,10,91,22]);

            csBtn=uiradiobutton(objButtons,"Text",'Charging Station',...
            'WordWrap','on','Position',[210,10,91,22]);

            obsBtn=uiradiobutton(objButtons,"Text",'Obstacle',...
            'WordWrap','on','Position',[310,10,91,22]);



            title=uilabel(AddObjPanelGrid,'Text',['Configure: ',objButtons.SelectedObject.Text]);
            title.Layout.Row=3;


            tbl=table([],[],'VariableNames',{'X','Y'});
            objTable=uitable(AddObjPanelGrid,'Data',tbl);
            objTable.ColumnEditable=[true,true];
            objTable.CellEditCallback=@(src,event)obj.MapDataMngr.objTableEdited(src,event);
            objTable.Layout.Row=4;
            obj.ObjTable=objTable;


        end
    end
end

