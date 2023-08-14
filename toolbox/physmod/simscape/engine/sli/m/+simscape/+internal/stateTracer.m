classdef stateTracer<handle














    properties(Access=public)
        UIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        GridLayout2 matlab.ui.container.GridLayout
        StateList matlab.ui.control.Table
        InfoList matlab.ui.control.Table
        StateAxes matlab.ui.control.UIAxes
        InfoAxes matlab.ui.control.UIAxes
InfoChart
Data
    end


    methods(Access=private)


        function StateListCellSelection(app,table,event)


            selectedRows=unique(event.Indices(:,1));
            if(isempty(selectedRows))
                return
            end
            idx=app.Data.system.values.index;
            plot(app.StateAxes,idx,app.Data.system.values.X(:,selectedRows));
            legend(app.StateAxes,{app.Data.system.states.X(selectedRows).path},'Interpreter','none');
            app.StateAxes.XLim=[1,max(idx)];
            app.SyncAxisCallback();
        end


        function InfoListCellSelection(app,~,event)
            indices=unique(event.Indices(:,1));
            for i=1:numel(app.InfoChart)
                if any(i==indices)
                    app.InfoChart(i).CData=[1,0,0];
                else
                    app.InfoChart(i).CData=[0,0,1];
                end
            end
        end

        function InfoScatterCallback(app,~,event)
            idx=event.IntersectionPoint(1);
            app.InfoList.Selection=find([app.Data.info.index]==idx);
            scroll(app.InfoList,'row',app.InfoList.Selection(1))

            for i=1:numel(app.InfoChart)
                if any(i==app.InfoList.Selection)
                    app.InfoChart(i).CData=[1,0,0];
                else
                    app.InfoChart(i).CData=[0,0,1];
                end
            end
        end

        function SyncAxisCallback(app,varargin)
            app.InfoAxes.XLim=app.StateAxes.XLim;
            drawnow;
            app.InfoAxes.InnerPosition=app.StateAxes.InnerPosition;
        end
    end


    methods(Access=private)


        function createComponents(app)


            app.UIFigure=uifigure('Visible','off');
            app.UIFigure.Position=[100,100,920,690];
            app.UIFigure.Name='Simscape Initialization State Tracer';
            app.UIFigure.AutoResizeChildren='off';
            app.UIFigure.SizeChangedFcn=@(varargin)app.SyncAxisCallback(varargin{:});


            app.GridLayout=uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth={'1x','3x'};
            app.GridLayout.RowHeight={'1x'};


            app.GridLayout2=uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth={'1x'};
            app.GridLayout2.RowHeight={'3x','1x'};
            app.GridLayout2.Layout.Row=1;
            app.GridLayout2.Layout.Column=2;


            app.StateAxes=uiaxes(app.GridLayout2);
            title(app.StateAxes,'Solve State')
            xlabel(app.StateAxes,'Index')

            app.StateAxes.Layout.Row=1;
            app.StateAxes.Layout.Column=1;
            app.StateAxes.XAxis.LimitsChangedFcn=@(varargin)app.SyncAxisCallback(varargin{:});
            app.StateAxes.YAxis.LimitsChangedFcn=@(varargin)app.SyncAxisCallback(varargin{:});
            app.StateAxes.PositionConstraint='innerposition';


            app.InfoAxes=uiaxes(app.GridLayout2);
            app.InfoAxes.Layout.Row=1;
            app.InfoAxes.Layout.Column=1;
            app.InfoAxes.XAxis.Visible=false;
            app.InfoAxes.YAxis.Visible=false;
            app.InfoAxes.PositionConstraint='innerposition';
            app.InfoAxes.Color='none';
            app.InfoAxes.Visible='off';
            axtoolbar(app.InfoAxes,{});
            disableDefaultInteractivity(app.InfoAxes);


            app.InfoList=uitable(app.GridLayout2);
            app.InfoList.ColumnName={'Index';'Solver';'Information';''};
            app.InfoList.RowName={};
            app.InfoList.SelectionType='row';
            app.InfoList.CellSelectionCallback=@(varargin)app.InfoListCellSelection(varargin{:});
            app.InfoList.Layout.Row=2;
            app.InfoList.Layout.Column=1;


            app.StateList=uitable(app.GridLayout);
            app.StateList.ColumnName={'State name';'std';'Type'};
            app.StateList.ColumnWidth={'2x','1x'};
            app.StateList.RowName={};
            app.StateList.SelectionType='row';
            app.StateList.ColumnSortable=true;
            app.StateList.CellSelectionCallback=@(varargin)app.StateListCellSelection(varargin{:});
            app.StateList.Layout.Row=1;
            app.StateList.Layout.Column=1;

        end
    end


    methods(Access=public)


        function app=stateTracer(stateTrace)


            createComponents(app)

            app.Data=stateTrace;


            infoTable=table([app.Data.info.index]',...
            string(app.Data.string([app.Data.info.solve]')),...
            string(app.Data.string([app.Data.info.label]')),...
            {app.Data.info.data}');

            app.InfoList.Data=infoTable;


            statesTable=table({app.Data.system.states.X.path}',std(app.Data.system.values.X,0,1)');
            app.StateList.Data=statesTable;

            app.InfoChart=scatter(app.InfoAxes,[app.Data.info.index],0,...
            'blue','filled',...
            'ButtonDownFcn',@(varargin)app.InfoScatterCallback(varargin{:}));
            app.InfoAxes.YLim=[0,1];


            app.UIFigure.Visible='on';


            app.SyncAxisCallback();
        end


        function delete(app)


            delete(app.UIFigure)
        end
    end
end