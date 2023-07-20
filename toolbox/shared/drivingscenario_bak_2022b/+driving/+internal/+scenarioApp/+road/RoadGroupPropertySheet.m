classdef RoadGroupPropertySheet<driving.internal.scenarioApp.road.PropertySheet

    properties
        ShowRoadGroupCenters=true
    end
    properties(Hidden)
hName
        MinWidth=0
hTable
hShowRoadGroupCenters
    end
    methods
        function this=RoadGroupPropertySheet(varargin)
            this@driving.internal.scenarioApp.road.PropertySheet(varargin{:});
        end
        function update(this)
            roadGroup=getSpecification(this);
            setupWidgets(this,roadGroup,{'Name'});
            app=this.Dialog.Application;
            canvas=app.ScenarioView;
            if this.Dialog.InteractiveMode
                tableData=getTableData(canvas);
            else
                tableData=deriveCenters(roadGroup);
            end
            set(this.hTable,'Data',tableData,...
            'RowName','numbered');
        end

        function updateLayout(this)
            layout=this.Layout;
            table=this.hTable;

            vw=0;
            tableRow=2;
            table.Visible='on';
            if this.ShowRoadGroupCenters
                if~layout.contains(table)
                    layout.insert('row',tableRow);
                    layout.add(table,tableRow,[1,1]);
                end
                table.Visible='on';
                vw=[0,1];
            else
                table.Visible='off';
                if layout.contains(table)
                    layout.remove(table);
                    layout.clean;
                end
            end
            layout.VerticalWeights=vw;
        end
        function w=getLabelMinimumWidth(this)
            w=this.MinWidth;
        end
    end
    methods(Access=protected)
        function createWidgets(this)
            p=this.Panel;
            layout=matlabshared.application.layout.GridBagLayout(p,...
            'VerticalWeights',1,...
            'HorizontalWeights',1,...
            'HorizontalGap',1);
            this.Layout=layout;

            columnNames={getString(message('driving:scenarioApp:XColumnName')),...
            getString(message('driving:scenarioApp:YColumnName')),...
            getString(message('driving:scenarioApp:ZColumnName'))};

            this.hTable=uitable('Parent',p,...
            'ColumnWidth','auto',...
            'Tag','RoadGroupCentersTable',...
            'Visible','on',...
            'ColumnName',columnNames,...
            'ColumnEditable',false);
            createToggle(this,p,'ShowRoadGroupCenters');
            layout.add(this.hShowRoadGroupCenters,1,1,...
            'TopInset',1,...
            'Anchor','NorthWest',...
            'Fill','Horizontal',...
            'MinimumWidth',layout.getMinimumWidth(this.hShowRoadGroupCenters)+20);
            setConstraints(layout,this.hTable,...
            'Fill','Both',...
            'MinimumWidth',120,...
            'MinimumHeight',100,...
            'Anchor','NorthWest');
            layout.add(this.hTable,2,[1,1]);
            layout.VerticalWeights=[0,1];
        end
    end
end