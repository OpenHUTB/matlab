classdef SignalViewDisplay<handle

    properties

ViewTable

SignalNameTable
SignalInfoTable

DeleteButton
    end

    properties(Access=private)
Parent

        CurrentBackgroundWhite=false;

BackupBackgroundColor
        IsBackgroundColorChange=false;
        LastSelection=[];
        CurrentlySelectedIndices=[];
    end

    properties(Constant)
        BackgroundWhite=[1.0,1.0,1.0];
        BackgroundGrey=[0.94,0.94,0.94];
    end


    events
DeleteSignal
ModifySignal
    end

    methods

        function this=SignalViewDisplay(parent,signalInfo)

            this.Parent=parent;

            addViewTable(this);

            addDeleteButton(this);

            updateOnSignalAdd(this,signalInfo);

        end

        function updateOnSignalAdd(this,signalInfo)

            if~isempty(signalInfo)
                numSignals=height(signalInfo);
                signalInfo=removevars(signalInfo,{'DisplayName'});

                signalTypeColumn=strings(numSignals,1);
                timeStampsColumn=strings(numSignals,1);

                for idx=1:numSignals

                    signalType=signalInfo{idx,'SignalType'};

                    if signalType==vision.labeler.loading.SignalType.Image
                        signalTypeColumn(idx)='Image';
                    elseif signalType==vision.labeler.loading.SignalType.PointCloud
                        signalTypeColumn(idx)='Point Cloud';
                    end

                    timeStamps=signalInfo{idx,'TimeStamp'};
                    timeStamps=timeStamps{1};

                    timeStampsColumn(idx)=string(timeStamps(1))+"-"+string(timeStamps(end));
                end

                signalInfo=removevars(signalInfo,{'SignalType','TimeStamp'});

                signalInfo=addvars(signalInfo,signalTypeColumn,...
                'After','SourceName','NewVariableNames','SignalType');
                signalInfo=addvars(signalInfo,timeStampsColumn,...
                'After','SignalType','NewVariableNames','TimeStamp');

                if~isUIFigureBased(this)
                    signalNameTable=signalInfo(:,{'SignalName'});
                    signalInfoTable=signalInfo(:,{'SourceName','SignalType','TimeStamp'});
                    signalNameData=cellstr(table2cell(signalNameTable));
                else
                    signalInfoTable=signalInfo(:,{'SignalName','SourceName','SignalType','TimeStamp'});
                end

                signalInfoData=cellstr(table2cell(signalInfoTable));

                if~isempty(this.SignalInfoTable.Data)
                    prevBackgroundColor=this.SignalInfoTable.BackgroundColor;

                    if~isUIFigureBased(this)
                        this.SignalNameTable.Data=vertcat(this.SignalNameTable.Data,signalNameData);
                    end
                    this.SignalInfoTable.Data=vertcat(this.SignalInfoTable.Data,signalInfoData);
                else
                    prevBackgroundColor=[];

                    if~isUIFigureBased(this)
                        this.SignalNameTable.Data=signalNameData;
                    end
                    this.SignalInfoTable.Data=signalInfoData;
                end

                uniqueSourceNames=unique(signalInfoTable.SourceName);

                backgroundColor=repmat([0,0,0],[numSignals,1]);

                for idx=1:numel(uniqueSourceNames)
                    if this.CurrentBackgroundWhite
                        color=this.BackgroundGrey;
                        this.CurrentBackgroundWhite=false;
                    else
                        color=this.BackgroundWhite;
                        this.CurrentBackgroundWhite=true;
                    end

                    indices=find(signalInfoTable.SourceName==uniqueSourceNames(idx));

                    for rowId=1:numel(indices)
                        row=indices(rowId);
                        backgroundColor(row,:)=color;
                    end

                end

                backgroundColor=[prevBackgroundColor;backgroundColor];

                if~isUIFigureBased(this)
                    this.SignalNameTable.BackgroundColor=backgroundColor;
                end
                this.SignalInfoTable.BackgroundColor=backgroundColor;

                this.BackupBackgroundColor=this.SignalInfoTable.BackgroundColor;
            end
        end


        function updateOnSignalDelete(this,deleteIndices)

            if~isempty(this.SignalInfoTable)
                numSignals=size(this.SignalInfoTable.Data,1);
                numDeleteIndices=numel(deleteIndices);

                if~isUIFigureBased(this)
                    this.SignalNameTable.Data(deleteIndices,:)=[];
                    if numSignals~=numDeleteIndices
                        this.SignalNameTable.BackgroundColor(deleteIndices,:)=[];
                    else
                        this.SignalNameTable.BackgroundColor=this.BackgroundWhite;
                    end
                end

                this.SignalInfoTable.Data(deleteIndices,:)=[];

                if numSignals~=numDeleteIndices
                    this.SignalInfoTable.BackgroundColor(deleteIndices,:)=[];
                else
                    this.SignalInfoTable.BackgroundColor=this.BackgroundWhite;
                end

                this.BackupBackgroundColor=this.SignalInfoTable.BackgroundColor;
            end

            this.DeleteButton.Enable='off';
        end

    end

    methods(Access=private)

        function addDeleteButton(this)
            if isUIFigureBased(this)
                this.DeleteButton=uibutton('Parent',this.Parent,...
                'Position',[5,10,125,25],...
                'Text',vision.getMessage('vision:labeler:DeleteButton'),...
                'Enable','off',...
                'ButtonPushedFcn',@this.deleteSignalCallback,...
                'Tag','loadDlgDeleteSelBtn');
            else
                this.DeleteButton=uicontrol('Parent',this.Parent,...
                'Style','pushbutton',...
                'Position',[5,10,125,25],...
                'String',vision.getMessage('vision:labeler:DeleteButton'),...
                'Enable','off',...
                'Callback',@this.deleteSignalCallback,...
                'Tag','loadDlgDeleteSelBtn');
            end
        end

        function addViewTable(this)

            signalNameColNames={'Signal Name'};

            signalInfoColNames={'Source','Signal Type',...
            'Time Range'};

            if~isUIFigureBased(this)

                signalNameColWidth={200};
                signalInfoColumnWidths={350,100,200};

                this.SignalNameTable=uitable(this.Parent,...
                'ColumnName',signalNameColNames,...
                'ColumnWidth',signalNameColWidth,...
                'CellSelectionCallback',@this.cellSelectionCallback,...
                'RowName','numbered',...
                'Position',[5,45,250,this.Parent.Position(4)-45],...
                'Tag','loadDlgSignalNameTable');

                this.SignalInfoTable=uitable(this.Parent,...
                'ColumnName',signalInfoColNames,...
                'ColumnWidth',signalInfoColumnWidths,...
                'CellSelectionCallback',@this.cellSelectionCallbackDummy,...
                'RowName',[],...
                'Position',[251,45,this.Parent.Position(3)-260-5,this.Parent.Position(4)-45],...
                'Tag','loadDlgSignalInfoTable');
            else
                signalInfoColNames=[signalNameColNames,signalInfoColNames];
                signalInfoColumnWidths={200,395,100,200};

                this.SignalInfoTable=uitable(this.Parent,...
                'ColumnName',signalInfoColNames,...
                'ColumnWidth',signalInfoColumnWidths,...
                'CellSelectionCallback',@this.cellSelectionCallbackUIFigBased,...
                'RowName',[],...
                'SelectionType','row',...
                'Position',[5,45,this.Parent.Position(3)-5,this.Parent.Position(4)-45],...
                'Tag','loadDlgSignalInfoTable');
            end
        end

    end




    methods(Access=private)
        function deleteSignalCallback(this,~,~)

            if~isUIFigureBased(this)
                selectedRows=unique(this.LastSelection(:,1));
            else
                selectedRows=this.LastSelection;
                this.LastSelection=[];
            end
            data=string(this.SignalInfoTable.Data);
            sourceNames=data(:,1);
            selectedSourceNames=sourceNames(selectedRows);
            uniqueSourceNames=unique(selectedSourceNames);
            deleteIndices=find(ismember(sourceNames,uniqueSourceNames));

            import vision.internal.videoLabeler.tool.signalLoading.events.*
            evtData=DeleteSignalEvent(deleteIndices);

            notify(this,'DeleteSignal',evtData);
        end

        function cellSelectionCallback(this,src,evtData)
            indices=evtData.Indices;

            if~isempty(indices)

                isLastSelection=~isempty(this.LastSelection)&&...
                size(this.LastSelection,1)==size(indices,1)&&...
                this.LastSelection(1)==indices(1);

                if~isLastSelection
                    backgroundColor=this.BackupBackgroundColor;

                    selectedRows=unique(indices(:,1));
                    data=string(this.SignalInfoTable.Data);
                    sourceNames=data(:,1);
                    selectedSourceNames=sourceNames(selectedRows);
                    uniqueSourceNames=unique(selectedSourceNames);

                    sourceIndices=find(ismember(sourceNames,uniqueSourceNames));
                    changeColorIndices=sourceIndices(~ismember(sourceIndices,indices(:,1)));

                    this.LastSelection=indices;

                    if~isempty(changeColorIndices)
                        backgroundColor(changeColorIndices,:)=repmat([0.0275,0.0902,0.8510],[size(changeColorIndices,1),1]);
                    end

                    this.IsBackgroundColorChange=~all(this.SignalNameTable.BackgroundColor(:)==backgroundColor(:));

                    if this.IsBackgroundColorChange
                        this.SignalNameTable.BackgroundColor=backgroundColor;
                    end
                else
                    this.IsBackgroundColorChange=false;
                end

                this.DeleteButton.Enable='on';
            else
                this.DeleteButton.Enable='off';

                if this.IsBackgroundColorChange
                    this.IsBackgroundColorChange=false;
                else
                    backgroundColor=this.BackupBackgroundColor;
                    isBackgroundColorChange=~all(this.SignalNameTable.BackgroundColor(:)==backgroundColor(:));
                    if isBackgroundColorChange
                        this.SignalNameTable.BackgroundColor=backgroundColor;
                    end
                    this.LastSelection=[];
                end
            end
        end

        function cellSelectionCallbackUIFigBased(this,src,evtData)
            indices=evtData.Indices;

            if~isempty(indices)

                selectedRows=unique(indices(:,1));
                unselectedRows=this.LastSelection(~ismember(this.LastSelection,selectedRows));

                data=string(this.SignalInfoTable.Data);
                sourceNames=data(:,2);

                unselectedSourceNames=sourceNames(unselectedRows);

                selectedSourceNames=sourceNames(selectedRows);
                unselectedSourceIndices=ismember(selectedSourceNames,unselectedSourceNames);
                selectedSourceNames=selectedSourceNames(~unselectedSourceIndices);
                selectionRowIndices=find(ismember(sourceNames,selectedSourceNames))';

                this.SignalInfoTable.Selection=selectionRowIndices;
                this.LastSelection=selectionRowIndices;


                this.DeleteButton.Enable='on';
            else
                this.DeleteButton.Enable='off';
                this.LastSelection=[];

            end
        end

        function cellSelectionCallbackDummy(this,src,evtData)
            temp=get(src,'Data');
            set(src,'Data',{'dummy'});
            set(src,'Data',temp);
        end
    end

    methods(Access=private)

        function TF=isUIFigureBased(this)
            TF=vision.internal.labeler.jtfeature('UseAppContainer');
        end
    end
end