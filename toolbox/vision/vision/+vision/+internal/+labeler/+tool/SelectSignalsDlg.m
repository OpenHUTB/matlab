classdef SelectSignalsDlg<handle

    properties(Dependent)
SelectedSignals
    end

    properties
SignalList
        SignalListModified=false;
        CheckBoxModified=false;
        IsActiveSignalChanged=false;
        IsNewDispFigSelected=false;
        IsOkButtonPressed=false;
        PrevActiveSignalIndex=[];
    end

    properties(Access=protected)
SelectSignalsFigure
OKButton
CancelButton
SignalNameTable
OldData
SelectSignalsButton
CurrentSelected
SelectedSignalInfo
    end

    properties(Access=protected)
LoadingFigurePos
SignalLoadPanelPos

OKButtonPos
CancelButtonPos
        CheckOnFigClose=false;
    end

    properties(Access=protected)

        LoadingDlgWidth=400;
        LoadingDlgHeight=300;


        OKCancelButtonY=10;
        OKCancelButtonHeight=30;
        OKCancelButtonWidth=50;
    end




    methods

        function this=SelectSignalsDlg(SelectSignalsButton)
            this.SelectSignalsButton=SelectSignalsButton;
            this.SignalList=struct('signalName',{},...
            'isVisible',{});
        end


        function show(this,activeSignalIndex)
            createDialog(this);
            addViewTable(this);
            updateOnSignalAdd(this,activeSignalIndex);
        end


        function close(this)
            close(this.SelectSignalsFigure);
        end


        function SignalInfo=get.SelectedSignals(this)
            isFigDispSameAsLastActiveDisp=~isequal(this.PrevActiveSignalIndex,this.CurrentSelected);


            if isempty(this.OldData)
                SignalInfo=this.SelectedSignalInfo;
                SignalInfo{this.CurrentSelected,1}=true;

            elseif(this.IsNewDispFigSelected&&~this.SelectedSignalInfo{this.CurrentSelected,1})
                SignalInfo=this.SelectedSignalInfo;
                if(isFigDispSameAsLastActiveDisp)
                    SignalInfo{this.CurrentSelected,1}=true;
                end


            elseif(~isequal(this.SelectedSignalInfo,this.OldData)&&...
                ~this.SelectedSignalInfo{this.CurrentSelected,1})
                SignalInfo=this.SelectedSignalInfo;
                SignalInfo{this.CurrentSelected,1}=true;

            elseif(isFigDispSameAsLastActiveDisp)
                SignalInfo=this.SelectedSignalInfo;
                SignalInfo{this.CurrentSelected,1}=true;
            else
                SignalInfo=this.SelectedSignalInfo;
            end



            if(~this.CheckBoxModified&&isFigDispSameAsLastActiveDisp&&...
                ~isempty(this.PrevActiveSignalIndex))
                if(~isequal(this.OldData,SignalInfo)&&~this.IsOkButtonPressed)
                    SignalInfo{this.PrevActiveSignalIndex,1}=false;
                end
            end
        end


        function setCurrentSelection(this,idx)
            this.CurrentSelected=idx;
        end


        function setDispFigSelection(this,flag)
            this.IsNewDispFigSelected=flag;
        end

        function updateSelectedSignals(this)
            signalInfo=this.SignalList;
            if~isempty(signalInfo)
                this.SelectedSignalInfo=horzcat({signalInfo.isVisible}',...
                cellstr({signalInfo.signalName}'));
            end
        end

    end




    methods(Access=protected)


        function createDialog(this)
            calculatePositions(this);
            if~useAppContainer
                this.SelectSignalsFigure=figure(...
                'Name',vision.getMessage('vision:labeler:SelectSignals'),...
                'Position',this.LoadingFigurePos,...
                'IntegerHandle','off',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'WindowStyle','modal',...
                'Visible','on',...
                'Resize','off',...
                'CloseRequestFcn',@this.closeRequestCallback,...
                'Tag','signalSelectionDlg');
            else
                this.SelectSignalsFigure=uifigure(...
                'Name',vision.getMessage('vision:labeler:SelectSignals'),...
                'Position',this.LoadingFigurePos,...
                'IntegerHandle','off',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'WindowStyle','modal',...
                'Visible','on',...
                'Resize','off',...
                'CloseRequestFcn',@this.closeRequestCallback,...
                'Tag','signalSelectionDlg');
            end
            addOKCancelButton(this);
        end


        function addOKCancelButton(this)
            if~useAppContainer
                this.OKButton=uicontrol('Parent',this.SelectSignalsFigure,...
                'Style','pushbutton',...
                'Position',this.OKButtonPos,...
                'String',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
                'Enable','on',...
                'Callback',@this.onOK,...
                'Tag','loadDlgOKButton');

                this.CancelButton=uicontrol('Parent',this.SelectSignalsFigure,...
                'Style','pushbutton',...
                'Position',this.CancelButtonPos,...
                'String',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
                'Enable','on',...
                'Callback',@this.onCancel,...
                'Tag','loadDlgCancelButton');
            else
                this.OKButton=uibutton('Parent',this.SelectSignalsFigure,...
                'Position',this.OKButtonPos,...
                'Text',vision.getMessage('MATLAB:uistring:popupdialogs:OK'),...
                'Enable','on',...
                'ButtonPushedFcn',@this.onOK,...
                'Tag','loadDlgOKButton');

                this.CancelButton=uibutton('Parent',this.SelectSignalsFigure,...
                'Position',this.CancelButtonPos,...
                'Text',vision.getMessage('MATLAB:uistring:popupdialogs:Cancel'),...
                'Enable','on',...
                'ButtonPushedFcn',@this.onCancel,...
                'Tag','loadDlgCancelButton');
            end
        end


        function addViewTable(this)
            signalNameColNames={'','Signal Name'};
            signalNameColWidth={25,325};
            this.SignalNameTable=uitable(this.SelectSignalsFigure,...
            'ColumnName',signalNameColNames,...
            'ColumnWidth',signalNameColWidth,...
            'ColumnEditable',[true,false],...
            'CellEditCallback',@this.cellSelectionCallback,...
            'RowName',[],...
            'BackgroundColor',[1,1,1],...
            'Position',[25,45,350,250],...
            'Tag','selectSignal');
        end


        function updateOnSignalAdd(this,activeSignalIndex)
            signalInfo=this.SignalList;
            this.IsActiveSignalChanged=~isequal(this.PrevActiveSignalIndex,activeSignalIndex);

            if~isempty(signalInfo)
                this.SignalNameTable.Data=horzcat({signalInfo.isVisible}',...
                cellstr({signalInfo.signalName}'));






                if(this.PrevActiveSignalIndex>numel(this.SignalNameTable.Data(:,1)))
                    this.PrevActiveSignalIndex=this.CurrentSelected;
                end
                isFigDispChanged=~any(strcmp(this.SignalNameTable.Data{this.CurrentSelected,2},...
                this.SignalNameTable.Data(this.PrevActiveSignalIndex,2)));

                if(this.IsActiveSignalChanged)
                    if(isFigDispChanged||this.IsNewDispFigSelected)
                        this.SignalNameTable.Data{this.CurrentSelected,1}=true;
                    end
                    this.OldData=this.SignalNameTable.Data;
                elseif(this.CheckBoxModified||~this.SignalNameTable.Data{this.CurrentSelected,1})


                    if(~isequal(this.SignalNameTable.Data,...
                        this.OldData)&&...
                        ~this.SignalNameTable.Data{this.CurrentSelected,1})
                        this.SignalNameTable.Data{this.CurrentSelected,1}=true;
                        this.OldData=this.SignalNameTable.Data;
                    else



                        this.SignalNameTable.Data=this.OldData;
                    end
                else
                    this.SignalNameTable.Data{this.CurrentSelected,1}=true;
                    this.OldData=this.SignalNameTable.Data;
                end
                this.PrevActiveSignalIndex=activeSignalIndex;
            end
        end


        function cellSelectionCallback(this,~,~)
            drawnow();
            this.SelectedSignalInfo=get(this.SignalNameTable,'Data');
            this.CheckBoxModified=true;
        end
    end

    methods

        function calculatePositions(this)

            screenSize=get(0,'ScreenSize');

            screenWidth=screenSize(3);
            screenHeight=screenSize(4);

            x=(screenWidth-this.LoadingDlgWidth)/2;
            y=(screenHeight-this.LoadingDlgHeight)/2;

            this.LoadingFigurePos=[x,y,this.LoadingDlgWidth,this.LoadingDlgHeight];

            okButtonX=(this.LoadingDlgWidth/2)-(this.OKCancelButtonWidth)-10;
            cancelButtonX=(this.LoadingDlgWidth/2)+10;

            this.OKButtonPos=[okButtonX,this.OKCancelButtonY...
            ,this.OKCancelButtonWidth,this.OKCancelButtonHeight];
            this.CancelButtonPos=[cancelButtonX,this.OKCancelButtonY...
            ,this.OKCancelButtonWidth,this.OKCancelButtonHeight];

        end


        function onOK(this,~,~)
            this.OKButton.Enable='off';
            this.CancelButton.Enable='off';
            this.OldData=this.SignalNameTable.Data;
            for i=1:numel(this.SignalList)
                this.SignalList(i).isVisible=this.SignalNameTable.Data{i,1};
            end
            this.SelectedSignalInfo=get(this.SignalNameTable,'Data');
            this.CheckOnFigClose=false;
            this.IsActiveSignalChanged=false;
            this.IsOkButtonPressed=true;
            close(this);
        end


        function onCancel(this,~,~)
            this.OKButton.Enable='off';
            this.CancelButton.Enable='off';
            this.SelectedSignalInfo=this.OldData;
            this.CheckOnFigClose=true;
            this.CheckBoxModified=false;
            close(this);
        end


        function closeRequestCallback(this,~,~)
            this.SelectedSignalInfo=this.OldData;
            this.CheckBoxModified=false;
            delete(this.SelectSignalsFigure);
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end