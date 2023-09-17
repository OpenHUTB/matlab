classdef DataStatisticsDialog<handle

    properties(Access={?tdatastats,?tDataStatisticsDialog})
        DataStatsUIFigure matlab.ui.Figure
        StatsTable matlab.ui.control.Table
        SavetoWorkSpaceButton matlab.ui.control.Button
        HelpButton matlab.ui.control.Button
        FigureDataManager datamanager.FigureDataManager
        DropDownList matlab.ui.control.DropDown
        InstructionLabel matlab.ui.control.Label
        DataChoiceLabel matlab.ui.control.Label
DataObjectHandles
CurrentObjectIndex
ParentFigure
SaveToWorkspaceDialog
    end

    properties(Access=?tDataStatisticsDialog,Constant)
        DIALOG_WIDTH=338
        DIALOG_HEIGHT=298
        NUM_OF_STATISTICS=7
        NUM_OF_COLS=4
    end

    methods

        function this=DataStatisticsDialog(parentFigure)
            if~isempty(basicfitdatastat('bfitFindProp',parentFigure,'Data_Stats_GUI_Object'))&&...
                ~isempty(parentFigure.Data_Stats_GUI_Object)
                this=parentFigure.Data_Stats_GUI_Object;
                this.bringToFront();
            else
                this.ParentFigure=parentFigure;
                this.FigureDataManager=datamanager.FigureDataManager.getInstance();
                this.createComponents();
            end
        end



        function closeDataStats(this)
            delete(this.SaveToWorkspaceDialog);
            delete(this.DataStatsUIFigure);
        end


        function close(this)
            delete(this.SaveToWorkspaceDialog);
            set(this.DataStatsUIFigure,'Visible','off');
        end




        function addData(this,hObjs,dataValues,currentObject,xstats,ystats,xcheck,ycheck)
            this.refreshStatisticsInfo(hObjs,dataValues,currentObject,xstats,ystats,xcheck,ycheck);
        end




        function removeData(this,hObjs,dataValues,currentObject,xstats,ystats,xcheck,ycheck,~,~)
            this.refreshStatisticsInfo(hObjs,dataValues,currentObject,xstats,ystats,xcheck,ycheck);
        end



        function removeStatLine(this,xcheck,ycheck)
            for rowInd=1:(this.NUM_OF_STATISTICS-1)
                this.StatsTable.Data{rowInd,this.NUM_OF_COLS-2}=xcheck(rowInd);
                this.StatsTable.Data{rowInd,this.NUM_OF_COLS}=ycheck(rowInd);
            end
        end



        function dataModified(this,xstats,ystats,xcolname,ycolname)
            this.updateStatsTable(xstats,ystats,false(this.NUM_OF_STATISTICS-1,1),false(this.NUM_OF_STATISTICS-1,1));
            this.updateColumnNames(xcolname,ycolname);
        end



        function updateColumnNames(this,xcolname,ycolname)
            this.StatsTable.ColumnName={xcolname;'';ycolname;''};
        end
    end


    methods(Access=?tDataStatisticsDialog)

        function bringToFront(this)
            set(this.DataStatsUIFigure,'Visible','on','Position',this.getDialogPosition());
            figure(this.DataStatsUIFigure);
        end


        function dialogPos=getDialogPosition(this)
            figPos=getpixelposition(this.ParentFigure);
            dialogPos=[figPos(1)+figPos(3)+5,figPos(2),this.DIALOG_WIDTH,this.DIALOG_HEIGHT];
            screenSize=get(0,'ScreenSize');
            if strcmpi(this.ParentFigure.WindowState,'maximized')
                dialogPos(1)=figPos(1)+figPos(3)-dialogPos(3);
                dialogPos(2)=figPos(2);
            elseif strcmpi(this.ParentFigure.WindowStyle,'docked')
                dialogPos(1)=screenSize(3)/3;
                dialogPos(2)=screenSize(4)/3;
            else
                xPos=abs(dialogPos(1));

                if xPos>screenSize(3)
                    xPos=xPos-screenSize(3);
                end
                if(xPos+dialogPos(3))>screenSize(3)
                    dialogPos(1)=figPos(1)-dialogPos(3)-5;
                    dialogPos(2)=figPos(2);
                end
            end
        end


        function createComponents(this)
            this.DataStatsUIFigure=this.FigureDataManager.getWarmedUpFigure();
            set(this.DataStatsUIFigure,...
            'CloseRequestFcn',@(e,d)this.close(),...
            'AutoResizeChildren','on');
            dialogName=getString(message('MATLAB:datamanager:datastats:FigureName'));
            figureNum=this.ParentFigure.Number;
            if isempty(figureNum)
                figureNum="";
            end
            if~isempty(this.ParentFigure.Name)
                this.DataStatsUIFigure.Name="Figure "+figureNum+" "+this.ParentFigure.Name+": "+dialogName;
            else
                this.DataStatsUIFigure.Name="Figure "+figureNum+": "+dialogName;
            end
            mainGridLayout=uigridlayout(this.DataStatsUIFigure);
            mainGridLayout.ColumnWidth={'1x'};
            mainGridLayout.RowHeight={'fit','fit',188,'fit'};
            dataGridLayout=uigridlayout(mainGridLayout,'Padding',[0,0,0,0]);
            dataGridLayout.ColumnWidth={'fit','1x'};
            dataGridLayout.RowHeight={'fit'};
            dataGridLayout.Layout.Row=1;
            dataGridLayout.Layout.Column=1;
            this.DataChoiceLabel=uilabel(dataGridLayout,...
            'Internal',true,...
            'Text',getString(message('MATLAB:datamanager:datastats:DropDownLabel')));
            this.DataChoiceLabel.Layout.Row=1;
            this.DataChoiceLabel.Layout.Column=1;
            this.DropDownList=uidropdown(dataGridLayout,...
            'Internal',true,...
            'Editable','off',...
            'ValueChangedFcn',@(e,d)this.selectedValueChanged(d));
            this.DropDownList.Layout.Row=1;
            this.DropDownList.Layout.Column=2;
            this.InstructionLabel=uilabel(mainGridLayout,...
            'Internal',true,...
            'Text',getString(message('MATLAB:datamanager:datastats:TableLabel')));
            this.InstructionLabel.Layout.Row=2;
            this.InstructionLabel.Layout.Column=1;
            this.StatsTable=uitable(mainGridLayout,...
            'Internal',true,...
            'ColumnName',{'X';'';'Y';''},...
            'ColumnEditable',[false,true,false,true],...
            'ColumnWidth',{'auto',30,'auto',30},...
            'RowName',{'min';'max';'mean';'median';'mode';'std';'range'},...
            'RowStriping','off',...
            'CellEditCallback',@(e,d)this.tableCellEditCallback(d));
            this.StatsTable.Layout.Row=3;
            this.StatsTable.Layout.Column=1;
            buttonGridLayout=uigridlayout(mainGridLayout,'Padding',[0,0,0,0]);
            buttonGridLayout.ColumnWidth={'1x',80,'fit'};
            buttonGridLayout.RowHeight={23};
            buttonGridLayout.Layout.Row=4;
            buttonGridLayout.Layout.Column=1;
            this.SavetoWorkSpaceButton=uibutton(buttonGridLayout,'push',...
            'Internal',true,...
            'Text',getString(message('MATLAB:datamanager:datastats:SaveToWorkspaceLabel')),...
            'ButtonPushedFcn',@(e,d)this.saveDataToWorkSpace());
            this.SavetoWorkSpaceButton.Layout.Row=1;
            this.SavetoWorkSpaceButton.Layout.Column=3;

            this.initStatisticsInfo();

            this.HelpButton=uibutton(buttonGridLayout,'push',...
            'Internal',true,...
            'Text',getString(message('MATLAB:datamanager:datastats:HelpLabel')),...
            'ButtonPushedFcn',@(e,d)this.openHelpPage());
            this.HelpButton.Layout.Row=1;
            this.HelpButton.Layout.Column=2;
            set(this.DataStatsUIFigure,'Visible','on',...
            'Position',this.getDialogPosition());
            internal.matlab.datatoolsservices.executeCmd('datamanager.FigureDataManager.warmUpFigure()');
        end

        function updateStatsTable(this,xstats,ystats,xcheck,ycheck)
            tableData=cell(this.NUM_OF_STATISTICS,this.NUM_OF_COLS);

            if this.CurrentObjectIndex<1
                this.SavetoWorkSpaceButton.Enable='off';
                this.StatsTable.Enable='off';
                this.StatsTable.ColumnName={'X';'';'Y';''};
            else

                if isempty(xstats)
                    xstats={'','','','','','',''};
                end
                if isempty(ystats)
                    ystats={'','','','','','',''};
                end
                if isempty(xcheck)
                    xcheck=false(this.NUM_OF_STATISTICS-1,1);
                end
                if isempty(ycheck)
                    ycheck=false(this.NUM_OF_STATISTICS-1,1);
                end

                for rowInd=1:this.NUM_OF_STATISTICS
                    if rowInd==this.NUM_OF_STATISTICS
                        tableData(rowInd,:)={xstats{rowInd},'',ystats{rowInd},''};
                    else
                        tableData(rowInd,:)={xstats{rowInd},xcheck(rowInd),ystats{rowInd},ycheck(rowInd)};
                    end
                end
                this.SavetoWorkSpaceButton.Enable='on';
                this.StatsTable.Enable='on';
            end

            this.StatsTable.Data=tableData;
        end


        function saveDataToWorkSpace(this)
            currentObj=this.DataObjectHandles(this.CurrentObjectIndex);
            if~isempty(this.SaveToWorkspaceDialog)&&...
                isvalid(this.SaveToWorkspaceDialog)
                delete(this.SaveToWorkspaceDialog);
            end
            this.SaveToWorkspaceDialog=basicfitdatastat("bfitsavedatastats",currentObj{1});
        end



        function initStatisticsInfo(this)
            this.CurrentObjectIndex=0;
            [hObjs,dataValues,xstats,ystats,xcheck,ycheck,xcolname,ycolname]=basicfitdatastat('bfitopen',this.ParentFigure,'ds');

            this.DataObjectHandles=hObjs;
            this.updateDropDownList(dataValues);
            if~isempty(this.DataObjectHandles)
                this.CurrentObjectIndex=1;
            end

            this.updateStatsTable(xstats,ystats,xcheck,ycheck);
            this.updateColumnNames(xcolname,ycolname);
            addStyle(this.StatsTable,uistyle('HorizontalAlignment','right'),'column',[1;3]);
        end


        function refreshStatisticsInfo(this,hObjs,displayValues,currentIndex,xstats,ystats,xcheck,ycheck)
            this.DataObjectHandles=hObjs;

            if currentIndex~=this.CurrentObjectIndex
                this.CurrentObjectIndex=currentIndex;
                this.updateStatsTable(xstats,ystats,xcheck,ycheck);
            end
            this.updateDropDownList(displayValues);
        end



        function updateDropDownList(this,dataValues)
            this.DropDownList.Items=dataValues;

            if isempty(dataValues)
                this.DropDownList.Enable='off';
                this.StatsTable.Data=cell(this.NUM_OF_STATISTICS,this.NUM_OF_COLS);
                this.StatsTable.ColumnName={'X';'';'Y';''};
            else
                this.DropDownList.ItemsData=rand(1,numel(dataValues));
                this.DropDownList.Enable='on';
                if this.CurrentObjectIndex~=0&&numel(dataValues)>=this.CurrentObjectIndex
                    this.DropDownList.Value=this.DropDownList.ItemsData(this.CurrentObjectIndex);
                end
            end
        end



        function openHelpPage(~)
            basicfitdatastat("bfithelp","ds");
        end



        function selectedValueChanged(this,d)
            this.CurrentObjectIndex=find(d.Source.ItemsData==d.Value);
            currentObj=this.DataObjectHandles(this.CurrentObjectIndex);
            [xstats,ystats,xcheck,ycheck]=basicfitdatastat("bfitdatastatupdate",this.ParentFigure,currentObj{1});
            this.updateStatsTable(xstats,ystats,xcheck,ycheck);
        end



        function tableCellEditCallback(this,d)

            if isempty(d.PreviousData)||d.Indices(1)>6
                d.Source.Data{d.Indices(1),d.Indices(2)}='';
                return;
            end
            currentObj=this.DataObjectHandles(this.CurrentObjectIndex);
            statsName=d.Source.RowName(d.Indices(1));
            statsCol='x';
            if(d.Indices(2)>2)
                statsCol='y';
            end
            basicfitdatastat("bfitplotdatastats",currentObj{1},statsName{1},statsCol,d.NewData);
        end
    end
end