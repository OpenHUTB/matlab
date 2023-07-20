classdef TableView<handle




    properties(Access=private)
AnalysisController
ImportController
NewSessionController
TableController
Table
    end

    methods(Hidden)

        function this=TableView(app,controllers)
            this.AnalysisController=controllers.analysisController;
            this.ImportController=controllers.importController;
            this.NewSessionController=controllers.newSessionController;
            this.TableController=controllers.tableController;
            this.addTable(app);
            this.subscribeToControllerEvents();
        end
    end

    methods(Access=private)
        function subscribeToControllerEvents(this)
            addlistener(this.AnalysisController,"UpdateTable",@(~,args)this.cb_UpdateTable(args));
            addlistener(this.AnalysisController,"DeleteTableRow",@(~,args)this.cb_DeleteRow(args));
            addlistener(this.AnalysisController,"RevertCellEdit",@(~,args)this.cb_SetSignalName(args));
            addlistener(this.AnalysisController,"RenameTableSignal",@(~,args)this.cb_SetSignalName(args));
            addlistener(this.AnalysisController,"UpdateTableSelection",@(~,args)this.cb_SelectRow(args));
            addlistener(this.ImportController,"UpdateTable",@(~,args)this.cb_UpdateTable(args));
            addlistener(this.ImportController,"UpdateTableSelection",@(~,args)this.cb_SelectRow(args));
            addlistener(this.NewSessionController,"ClearTable",@(~,~)this.cb_ClearTableData());
            addlistener(this.TableController,"UpdateTableSelection",@(~,args)this.cb_SelectRow(args));
        end


        function cb_ClearTableData(this)
            this.Table.Data=[];
        end

        function cb_UpdateTable(this,args)
            row=args.Data.tableData;
            if isempty(this.Table.Data)
                signalNames=[];
            else
                signalNames=this.Table.Data(:,1);
            end
            if~any(strcmp(signalNames,row(1)))

                this.Table.Data=[this.Table.Data;row];
            else

                idx=find(strcmp(signalNames,row(1)));
                this.Table.Data(idx,:)=row;
            end
        end

        function cb_SelectRow(this,args)
            signalNames=this.Table.Data(:,1);
            row=find(strcmp(signalNames,args.Data.name));
            this.Table.Selection=row;
        end

        function cb_SetSignalName(this,args)
            row=args.Data.indices(1);
            col=args.Data.indices(2);
            this.Table.Data(row,col)=args.Data.name;
        end

        function cb_DeleteRow(this,args)
            name=args.Data.name;
            signalNames=this.Table.Data(:,1);
            row=find(strcmp(signalNames,name));
            this.Table.Data(row,:)=[];

            eventData.Source=this.Table;
            if row~=1
                eventData.Indices=row-1;
                this.Table.Selection=row-1;
            elseif row==1&&length(signalNames)~=1
                eventData.Indices=1;
                this.Table.Selection=1;
            else
                eventData.Indices=[];
            end
            this.TableController.cb_TableSelectionChanged(eventData,true);
        end


        function addTable(this,app)

            panelOptions.Title=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:tableTitle")));
            panelOptions.Region="left";
            panel=matlab.ui.internal.FigurePanel(panelOptions);
            app.add(panel);


            gridLayout=uigridlayout(panel.Figure,[1,1]);
            nameLabel=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:nameLabel")));
            typeLabel=string(getString(message("wavelet_tfanalyzer:wavelettfanalyzer:typeLabel")));
            this.Table=uitable(gridLayout,"RowName",[],"ColumnName",[nameLabel,typeLabel],"Multiselect","off","SelectionType","row",...
            "ColumnEditable",[true,false],"ColumnWidth","1x");
            this.Table.CellSelectionCallback=@(~,event)this.TableController.cb_TableSelectionChanged(event,false);
            this.Table.CellEditCallback=@(~,event)this.AnalysisController.cb_RenameSignal(event);
            this.Table.Tag="signalTable";
        end
    end

end
